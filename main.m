//
//  main.m
//  Cocoa Slides MacRuby
//
//  Created by Matthew Smith on 8/28/10.
//  Copyright Apple Inc. 2010. All rights reserved.
//

#import <MacRuby/MacRuby.h>

int main(int argc, char *argv[])
{
    return macruby_main("rb_main.rb", argc, argv);
}
