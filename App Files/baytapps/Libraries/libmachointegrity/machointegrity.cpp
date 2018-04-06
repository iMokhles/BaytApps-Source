//
//  machointegrity.cpp
//  machointegrity
//
//  Created by Bailey Seymour on 9/15/16.
//  Copyright © 2016 Bailey Seymour. All rights reserved.
//

#import <stdio.h>
#import <stdlib.h>
#import <CommonCrypto/CommonCrypto.h>
#import "machointegrity.hpp"

/* Get the next load command from the current one */
#define NEXTCMD(cmd) (struct load_command*)((char*)(cmd) + (cmd)->cmdsize)

/* Iterate through all load commands */
#define ITERCMDS(i, cmd, cmds, ncmds) for(i = 0, cmd = (cmds); i < (ncmds); i++, cmd = NEXTCMD(cmd))


#ifdef __LITTLE_ENDIAN__
#define swap_if_necessary(value) (OSSwapLittleToHostInt32(value))
#else
#define swap_if_necessary(value) (value)
#endif

namespace mi {

void integrity::print_all_vec_style(std::vector<std::string> vec)
{
//    std::cout << "{\n";
    for (std::size_t ii=0; ii < vec.size(); ii++)
    {
        std::string item = vec.at(ii);
        std::string comma = ",";
        if ((ii+1) == vec.size()) comma = ""; // no comma on last item
        
        std::cout << "\"" << item << "\"" << comma << std::endl;
    }
//    std::cout << "}\n";
}


bool integrity::is_running_64_bit(void)
{
    if (sizeof(int*) == 4) //system is 32-bit
        return false;
    else if (sizeof(int*) == 8) //system is 64-bit
        return true;
}

bool integrity::header_is_64_bit(struct mach_header *slice)
{
    bool is64bit = false;
    
    if (slice->magic != MH_MAGIC && slice->magic != MH_CIGAM)
    {
        if(slice->magic == MH_MAGIC_64 || slice->magic == MH_CIGAM_64)
        {
            is64bit = true;
        }
    }
    
    return is64bit;
}
    
bool integrity::header_matches_running_arch(struct mach_header *slice)
{
    if (integrity::header_is_64_bit(slice) && integrity::is_running_64_bit())
        return true;
    else if (!integrity::header_is_64_bit(slice) && !integrity::is_running_64_bit())
        return true;
    
    
    return false;
}

integrity::integrity(std::string path)
{
    FILE *buf = fopen(path.c_str(), "r");
    
    if (buf == NULL)
    {
        throw error("failed to read mach-o file", macho_read_file_error);
    }
    
    fseek(buf, 0, SEEK_END);
    this->buffer_size = ftell(buf);
    rewind(buf);
    
    this->buffer = reinterpret_cast<struct mach_header *>(malloc((this->buffer_size + 1) * sizeof(struct mach_header)));
    fread(buffer, this->buffer_size, 1, buf);
    
    fclose(buf);
}

integrity::~integrity(void)
{
    free(this->buffer);
}

std::vector<std::string> integrity::get_dylib_list(struct mach_header *slice)
{
    std::vector<std::string> dylib_list;
    
    struct load_command *cmd, *cmds = NULL;
    uint32_t i, ncmds;
    bool is64bit_header = integrity::header_is_64_bit(slice);
    
    
    /* Parse mach_header to get the first load command and the number of commands */
    if (is64bit_header)
    {
        struct mach_header_64* mh64 = (struct mach_header_64*)slice;
        cmds = (struct load_command*)&mh64[1];
        ncmds = mh64->ncmds;
    }
    else
    {
        cmds = (struct load_command*)&slice[1];
        ncmds = slice->ncmds;
    }
    
    
    ITERCMDS(i, cmd, cmds, ncmds)
    {
        /* Make sure we don't loop infinitely */
        if(cmd->cmdsize == 0)
        {
            break;
        }
        
        if((uintptr_t)cmd + cmd->cmdsize - (uintptr_t)slice > this->buffer_size)
        {
            break;
        }
        
        
        switch(cmd->cmd)
        {
            case LC_LOAD_DYLIB:
            {
                struct dylib_command *dyc = (struct dylib_command *)cmd;
                
                uint32_t pathOffset = dyc->dylib.name.offset;
                char *dylibName = (char *)dyc + pathOffset;
                
                dylib_list.push_back(std::string(dylibName));
                
                break;
            }
                
            default:
                continue;
        }
    }
    
    return dylib_list;
}
template <typename seg, typename sect>
std::string inline get_sig(seg segment, sect section, struct mach_header *slice)
{
    
    // Get here the __text section address, the __text section size
    // and the virtual memory address so we can calculate
    // a pointer on the __text section
    uint32_t *textSectionAddr = reinterpret_cast<uint32_t *>(section->addr);
    unsigned int textSectionSize = static_cast<unsigned int>(section->size);
    uint32_t *vmaddr = reinterpret_cast<uint32_t *>(segment->vmaddr);
    char * textSectionPtr = (char *)((off_t)slice + (off_t)textSectionAddr - (off_t)vmaddr);
    // Calculate the signature of the data,
    // store the result in a string
    // and compare to the original one
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    char signature[2 * CC_MD5_DIGEST_LENGTH];            // will hold the signature
    CC_MD5(textSectionPtr, textSectionSize, digest);     // calculate the signature
    for (int i = 0; i < sizeof(digest); i++)             // fill signature
        sprintf(signature + (2 * i), "%02x", digest[i]);
    
    return signature;
    //return strcmp(originalSignature, signature) == 0;    // verify signatures match
}

std::string integrity::get_section_signature(struct mach_header *slice, std::string segment_name, std::string section_name)
{
    std::vector<std::string> dylib_list;
    
    struct load_command *cmd, *cmds = NULL;
    uint32_t i, ncmds;
    bool is64bit_header = integrity::header_is_64_bit(slice);
    
    
    /* Parse mach_header to get the first load command and the number of commands */
    if (is64bit_header)
    {
        struct mach_header_64* mh64 = (struct mach_header_64*)slice;
        cmds = (struct load_command*)&mh64[1];
        ncmds = mh64->ncmds;
    }
    else
    {
        cmds = (struct load_command*)&slice[1];
        ncmds = slice->ncmds;
    }
    
    
    ITERCMDS(i, cmd, cmds, ncmds)
    {
        /* Make sure we don't loop infinitely */
        if(cmd->cmdsize == 0)
        {
            break;
        }
        
        if((uintptr_t)cmd + cmd->cmdsize - (uintptr_t)slice > this->buffer_size)
        {
            break;
        }
        
        
        switch(cmd->cmd)
        {
            case LC_SEGMENT:
            {
                struct segment_command *segment = (struct segment_command *)cmd;
                bool has_segment = false;
                if (!strcmp(segment->segname, segment_name.c_str()))
                {
                    has_segment = true;
                    struct section *section = (struct section *)(segment + 1);
                    
                    bool has_section = false;
                    for (uint32_t j = 0; section != NULL && j < segment->nsects; j++) {
                        if (!strcmp(section->sectname, section_name.c_str()))
                        {
                            has_section = true;
                            break; //Stop on __text section load command
                        }
                        
                        section = (struct section *)(section + 1);
                    }
                    
                    if (!has_section)
                        throw error("no mach-o section found", section_not_found_error);
                    
                    return get_sig<struct segment_command *, struct section *>(segment, section, slice);
                }
                
                if (!has_segment)
                    throw error("no mach-o segment found", segment_not_found_error);
                
            }
            case LC_SEGMENT_64:
            {
                struct segment_command_64 *segment64 = (struct segment_command_64 *)cmd;
                bool has_segment = false;
                if (!strcmp(segment64->segname, segment_name.c_str()))
                {
                    has_segment = true;
                    struct section_64 *section64 = (struct section_64 *)(segment64 + 1);
                    
                    bool has_section = false;
                    for (uint32_t j = 0; section64 != NULL && j < segment64->nsects; j++) {
                        if (!strcmp(section64->sectname, section_name.c_str()))
                        {
                            has_section = true;
                            break; //Stop on __text section load command
                        }
                        
                        section64 = (struct section_64 *)(section64 + 1);
                    }
                    
                    if (!has_section)
                        throw error("no section found", section_not_found_error);
                    
                    return get_sig<struct segment_command_64 *, struct section_64 *>(segment64, section64, slice);
                }
                
//                if (!has_segment)
//                    throw error("no segment found", segment_not_found_error);
                
            }
                
            default:
                continue;
        }
    }
    
    return std::string("");
}

std::vector<struct mach_header *> integrity::get_all_headers(void)
{
    struct mach_header *tmp = NULL;
    uint32_t slices = 1;
    off_t off = 0;
    
    std::vector<struct mach_header *> headers;
    
    if (buffer->magic == FAT_MAGIC || buffer->magic == FAT_CIGAM)
    {
        // fat archive
        slices = (uint32_t)swap_if_necessary((((struct fat_header *)buffer)->nfat_arch));
        
        while (off < buffer_size) {
            
            tmp = (struct mach_header *)((off_t)buffer + off);
            if (tmp->magic == MH_MAGIC || tmp->magic == MH_CIGAM
                || tmp->magic == MH_MAGIC_64 || tmp->magic == MH_CIGAM_64)
            {
                headers.push_back(tmp);
            }
            off++;
        }
    }
    else
    {
        // thin archive
        headers.push_back(buffer);
    }
    
    
    return headers;
}

}
