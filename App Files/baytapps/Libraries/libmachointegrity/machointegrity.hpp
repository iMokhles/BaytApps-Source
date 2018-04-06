//
//  machointegrity.h
//  machointegrity
//
//  Created by Bailey Seymour on 9/14/16.
//  Copyright © 2016 Bailey Seymour. All rights reserved.
//

#ifndef machointegrity_h
#define machointegrity_h

#import <vector>
#import <string>
#import <mach-o/loader.h>
#import <mach-o/fat.h>
#import <iostream>


namespace mi
{
    static const std::string segment_text = "__TEXT";
    static const std::string segment_data = "__DATA";
    static const std::string segment_objc = "__OBJC";
    static const std::string text_section_text = "__text";
    static const std::string text_section_cstring = "__cstring";
    static const std::string text_section_picsymbol_stub = "__picsymbol_stub";
    static const std::string text_section_symbol_stub = "__symbol_stub";
    static const std::string text_section_const = "__const";
    
    typedef enum : int {
        macho_read_file_error,
        segment_not_found_error,
        section_not_found_error
    } error_code;
    
class error : public std::runtime_error {
    
    
public:
    
    
    error(const std::string& message, mi::error_code code) : std::runtime_error(message)
    {
        msg_ = message;
        this->code = code;
    }
    
    mi::error_code code;
    
    virtual const char* what() const throw ()
    {
        return msg_.c_str();
    }
    
protected:
    std::string msg_;
};

class integrity {
private:
    // current open file (path specified in class constructor)
    struct mach_header *buffer;
    long buffer_size;
    
public:
    integrity(std::string filepath);
    
    ~integrity(void);
    
    // gets all mach headers from the current open file/buffer
    std::vector<struct mach_header *> get_all_headers(void);
    
    // lists all linked dylibs inside of a mach header
    std::vector<std::string> get_dylib_list(struct mach_header *slice);
    
    // returns a signature of a segment's section via: MD5(char *section + unsigned int section_size)
    std::string get_section_signature(struct mach_header *slice, std::string segment_name, std::string section_name);
    
    // helper function to print all linked dylibs in vector = {} form
    static void print_all_vec_style(std::vector<std::string> vec);
    
    static bool is_running_64_bit(void);
    static bool header_is_64_bit(struct mach_header *slice);
    
    // mach header matches running arch/32bit/64bit. useful when only wanting the current open slice.
    static bool header_matches_running_arch(struct mach_header *slice);
};
}

#endif /* machointegrity_h */
