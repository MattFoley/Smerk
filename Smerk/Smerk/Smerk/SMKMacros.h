//
//  SMKMacros.h
//  Smerk
//
//  Created by teejay on 1/22/14.
//  Copyright (c) 2014 Smerk. All rights reserved.
//

#ifndef Smerk_SMKMacros_h
#define Smerk_SMKMacros_h

#ifndef DLog
#   ifdef DEBUG
#       define DLog(...) NSLog(__VA_ARGS__)
#   else
#       define DLog(...) /* */
#   endif
#endif

#ifndef UIInterfaceIdiomIsPad
#   define UIInterfaceIdiomIsPad() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#endif

#endif
