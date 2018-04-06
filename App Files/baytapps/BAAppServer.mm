//
//  BAAppServer.m
//  baytapps
//
//  Created by iMokhles on 04/11/2016.
//  Copyright © 2016 iMokhles. All rights reserved.


//#import "UICKeyChainStore.h"
#import "BAAppServer.h"
#include "machointegrity.hpp"
#include <cstdlib>
#include <ctime>
#include <cstring>
#include <string>
#include <cctype>

//UICKeyChainStore *keyWrapper = [UICKeyChainStore keyChainStoreWithService:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]];

using namespace std;
void Encrypt(string&);
string Decrypt(string strTarget);

void Encrypt(string &strTarget)
{
    int len = strTarget.length();
    char a;
    string strFinal(strTarget);
    
    for (int i = 0; i <= (len-1); i++)
    {
        a = strTarget.at(i);
        int b = (int)a; //get the ASCII value of 'a'
        b += 2; //Mulitply the ASCII value by 2
        if (b > 254) { b = 254; }
        a = (char)b; //Set the new ASCII value back into the char
        strFinal.insert(i , 1, a); //Insert the new Character back into the string
    }
    string strEncrypted(strFinal, 0, len);
    strTarget = strEncrypted;
}

string Decrypt(string strTarget)
{
    int len = strTarget.length();
    char a;
    string strFinal(strTarget);
    
    for (int i = 0; i <= (len-1); i++)
    {
        a = strTarget.at(i);
        int b = (int)a;
        b -= 2;
        
        a = (char)b;
        strFinal.insert(i, 1, a);
    }
    string strDecrypted(strFinal, 0, len);
    return strDecrypted;
}

static void my_verify_dylibs(std::vector<std::string> dylibs, bool *contains_unexpected)
{
    std::vector<std::string> expected_dylibs = {
        "1U{uvgo1Nkdtct{1Htcogyqtmu1Uqekcn0htcogyqtm1Uqekcn",
        "1U{uvgo1Nkdtct{1Htcogyqtmu1Ceeqwpvu0htcogyqtm1Ceeqwpvu",
        "1wut1nkd1nkd|030f{nkd",
        "1U{uvgo1Nkdtct{1Htcogyqtmu1KocigKQ0htcogyqtm1KocigKQ",
        "1wut1nkd1nkdusnkvg50f{nkd",
        "1U{uvgo1Nkdtct{1Htcogyqtmu1Hqwpfcvkqp0htcogyqtm1Hqwpfcvkqp",
        "1wut1nkd1nkdqdle0C0f{nkd",
        "1wut1nkd1nkde--030f{nkd",
        "1wut1nkd1nkdU{uvgo0D0f{nkd",
        "1U{uvgo1Nkdtct{1Htcogyqtmu1CXHqwpfcvkqp0htcogyqtm1CXHqwpfcvkqp",
        "1U{uvgo1Nkdtct{1Htcogyqtmu1Ceegngtcvg0htcogyqtm1Ceegngtcvg",
        "1U{uvgo1Nkdtct{1Htcogyqtmu1CfftguuDqqm0htcogyqtm1CfftguuDqqm",
        "1U{uvgo1Nkdtct{1Htcogyqtmu1CwfkqVqqndqz0htcogyqtm1CwfkqVqqndqz",
        "1U{uvgo1Nkdtct{1Htcogyqtmu1EqtgHqwpfcvkqp0htcogyqtm1EqtgHqwpfcvkqp",
        "1U{uvgo1Nkdtct{1Htcogyqtmu1EqtgItcrjkeu0htcogyqtm1EqtgItcrjkeu",
        "1U{uvgo1Nkdtct{1Htcogyqtmu1EqtgKocig0htcogyqtm1EqtgKocig",
        "1U{uvgo1Nkdtct{1Htcogyqtmu1EqtgNqecvkqp0htcogyqtm1EqtgNqecvkqp",
        "1U{uvgo1Nkdtct{1Htcogyqtmu1EqtgOgfkc0htcogyqtm1EqtgOgfkc",
        "1U{uvgo1Nkdtct{1Htcogyqtmu1NqecnCwvjgpvkecvkqp0htcogyqtm1NqecnCwvjgpvkecvkqp",
        "1U{uvgo1Nkdtct{1Htcogyqtmu1OcrMkv0htcogyqtm1OcrMkv",
        "1U{uvgo1Nkdtct{1Htcogyqtmu1OgfkcRnc{gt0htcogyqtm1OgfkcRnc{gt",
        "1U{uvgo1Nkdtct{1Htcogyqtmu1OguucigWK0htcogyqtm1OguucigWK",
        "1U{uvgo1Nkdtct{1Htcogyqtmu1OqdkngEqtgUgtxkegu0htcogyqtm1OqdkngEqtgUgtxkegu",
        "1U{uvgo1Nkdtct{1Htcogyqtmu1Swctv|Eqtg0htcogyqtm1Swctv|Eqtg",
        "1U{uvgo1Nkdtct{1Htcogyqtmu1SwkemNqqm0htcogyqtm1SwkemNqqm",
        "1U{uvgo1Nkdtct{1Htcogyqtmu1Ugewtkv{0htcogyqtm1Ugewtkv{",
        "1U{uvgo1Nkdtct{1Htcogyqtmu1UvqtgMkv0htcogyqtm1UvqtgMkv",
        "1U{uvgo1Nkdtct{1Htcogyqtmu1U{uvgoEqphkiwtcvkqp0htcogyqtm1U{uvgoEqphkiwtcvkqp",
        "1U{uvgo1Nkdtct{1Htcogyqtmu1WKMkv0htcogyqtm1WKMkv",
        "1wut1nkd1nkde--cdk0f{nkd",
        "1wut1nkd1nkdU{uvgo0f{nkd"
    };
    for (std::size_t ii=0; ii < dylibs.size(); ii++)
    {
        
        std::string dylib_path =  dylibs.at(ii);//Encrypt();
        
        Encrypt(dylib_path);
        
        if (std::find(expected_dylibs.begin(), expected_dylibs.end(), dylib_path) != expected_dylibs.end())
        {
//            std::cout << "expected: " << dylib_path << std::endl;
            ///[keyWrapper setString:@"YES" forKey:@"checkingLicense"];
//            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"checkingLicense"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            *contains_unexpected = true;
//            std::cout << "*** unexpected: " << dylib_path << std::endl;
            ///[keyWrapper setString:@"YES" forKey:@"checkingLicense"];
//            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"checkingLicense"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
    }
}

__attribute__((constructor))
static void init()
{
    NSArray *args = [[NSProcessInfo processInfo] arguments];
    
    try
    {

        mi::integrity mi(([args[0] UTF8String]));
        std::vector<struct mach_header *> headers = mi.get_all_headers();

        for (size_t i=0; i < headers.size(); i++)
        {
            if (headers.at(i))
            {
                if (mi::integrity::header_matches_running_arch(headers.at(i)))
                {
                    std::vector<std::string> dylibs = mi.get_dylib_list(headers.at(i));
                    // helper function to print all linked dylibs in vector = {} form
//                    mi::integrity::print_all_vec_style(dylibs);

                    try {
                        std::string section_sig = mi.get_section_signature(headers.at(i), mi::segment_text, mi::text_section_text);
                        std::cout << section_sig << std::endl;
                    } catch(mi::error &e)
                    {
                        std::cout << e.what() << std::endl;
                    };

                    bool unexpected;
                    my_verify_dylibs(dylibs, &unexpected);
                    if (unexpected)
                    {
                        
//                        exit(EXIT_FAILURE);
                    }
                }
            }
        }
    }
    catch (mi::error &e)
    {
        if (e.code == mi::macho_read_file_error)
        {
            
            
           // [keyWrapper setString:@"YES" forKey:@"checkingLicense"];
            
//            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"checkingLicense"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            exit(EXIT_FAILURE);
        }
        else std::cout << e.what() << std::endl;
    }

}
