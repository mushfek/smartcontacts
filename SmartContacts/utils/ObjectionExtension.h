//
// Created by Sharafat Ibn Mollah Mosharraf on 5/26/14.
// Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import "JSObjection.h"


#define objection_inject(value) [[JSObjection defaultInjector] getObject:[value class]];
