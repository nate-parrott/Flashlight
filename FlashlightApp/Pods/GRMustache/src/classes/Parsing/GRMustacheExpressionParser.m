// The MIT License
//
// Copyright (c) 2014 Gwendal Roué
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "GRMustacheExpressionParser_private.h"
#import "GRMustacheImplicitIteratorExpression_private.h"
#import "GRMustacheFilteredExpression_private.h"
#import "GRMustacheIdentifierExpression_private.h"
#import "GRMustacheScopedExpression_private.h"
#import "GRMustacheError.h"

@implementation GRMustacheExpressionParser

- (GRMustacheExpression *)parseExpression:(NSString *)string empty:(BOOL *)empty error:(NSError **)error
{
    //    -> ;;sm_parenLevel=0 -> stateInitial
    //    stateInitial -> ' ' -> stateInitial
    //    stateInitial -> '.' -> stateLeadingDot
    //    stateInitial -> 'a' -> stateIdentifier
    //    stateInitial -> sm_parenLevel==0;EOF; -> stateEmpty
    //    stateLeadingDot -> 'a' -> stateIdentifier
    //    stateLeadingDot -> ' ' -> stateIdentifierDone
    //    stateIdentifier -> '(';++sm_parenLevel -> stateInitial
    //    stateLeadingDot -> sm_parenLevel>0;')';--sm_parenLevel -> stateFilterDone
    //    stateLeadingDot -> sm_parenLevel==0;EOF; -> stateValid
    //    stateIdentifier -> 'a' -> stateIdentifier
    //    stateIdentifier -> '.' -> stateWaitingForIdentifier
    //    stateIdentifier -> ' ' -> stateIdentifierDone
    //    stateIdentifier -> '(';++sm_parenLevel -> stateInitial
    //    stateIdentifier -> sm_parenLevel>0;')';--sm_parenLevel -> stateFilterDone
    //    stateIdentifier -> sm_parenLevel==0;EOF; -> stateValid
    //    stateWaitingForIdentifier -> 'a' -> stateIdentifier
    //    stateIdentifierDone -> ' ' -> stateIdentifierDone
    //    stateIdentifierDone -> sm_parenLevel==0;EOF; -> stateValid
    //    stateIdentifierDone -> '(';++sm_parenLevel -> stateInitial
    //    stateFilterDone -> ' ' -> stateFilterDone
    //    stateFilterDone -> '.' -> stateWaitingForIdentifier
    //    stateFilterDone -> '(';++sm_parenLevel -> stateInitial
    //    stateFilterDone -> sm_parenLevel==0;EOF; -> stateValid
    //    stateFilterDone -> sm_parenLevel>0;')';--sm_parenLevel -> stateFilterDone
    
    // state machine internal states
    enum {
        stateInitial,
        stateLeadingDot,
        stateIdentifier,
        stateWaitingForIdentifier,
        stateIdentifierDone,
        stateFilterDone,
        stateEmpty,
        stateError,
        stateValid
    } state = stateInitial;
    NSUInteger identifierStart = NSNotFound;
    NSMutableArray *filterExpressionStack = [NSMutableArray array];
    GRMustacheExpression *currentExpression=nil;
    GRMustacheExpression *validExpression=nil;
    
    NSUInteger length = string.length;
    for (NSUInteger i = 0; i < length; ++i) {
        
        // shortcut
        if (state == stateError) {
            break;
        }
        
        unichar c = [string characterAtIndex:i];
        switch (state) {
            case stateInitial:
                switch (c) {
                    case ' ':
                    case '\r':
                    case '\n':
                    case '\t':
                        break;
                        
                    case '.':
                        NSAssert(currentExpression == nil, @"WTF expected nil currentExpression");
                        state = stateLeadingDot;
                        currentExpression = [GRMustacheImplicitIteratorExpression expression];
                        break;
                        
                    case '(':
                        state = stateError;
                        break;
                        
                    case ')':
                        state = stateError;
                        break;
                        
                    case ',':
                        state = stateError;
                        break;
                        
                    case '{':
                    case '}':
                    case '&':
                    case '$':
                    case '#':
                    case '^':
                    case '/':
                    case '<':
                    case '>':
                        // invalid as an identifier start
                        state = stateError;
                        break;
                        
                    default:
                        state = stateIdentifier;
                        
                        // enter stateIdentifier
                        identifierStart = i;
                        break;
                }
                break;
                
            case stateLeadingDot:
                switch (c) {
                    case ' ':
                    case '\r':
                    case '\n':
                    case '\t':
                        state = stateIdentifierDone;
                        break;
                        
                    case '.':
                        state = stateError;
                        break;
                        
                    case '(': {
                        NSAssert(currentExpression, @"WTF expected currentExpression");
                        state = stateInitial;
                        [filterExpressionStack addObject:currentExpression];
                        currentExpression = nil;
                    } break;
                        
                    case ')':
                        if (filterExpressionStack.count > 0) {
                            NSAssert(currentExpression, @"WTF expected currentExpression");
                            NSAssert(filterExpressionStack.count > 0, @"WTF expected non empty filterExpressionStack");
                            
                            state = stateFilterDone;
                            GRMustacheExpression *filterExpression = [filterExpressionStack lastObject];
                            [filterExpressionStack removeLastObject];
                            currentExpression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:currentExpression curried:NO];
                        } else {
                            state = stateError;
                        }
                        break;
                        
                    case ',':
                        if (filterExpressionStack.count > 0) {
                            NSAssert(currentExpression, @"WTF expected currentExpression");
                            NSAssert(filterExpressionStack.count > 0, @"WTF expected non empty filterExpressionStack");
                            
                            state = stateInitial;
                            GRMustacheExpression *filterExpression = [filterExpressionStack lastObject];
                            [filterExpressionStack removeLastObject];
                            [filterExpressionStack addObject:[GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:currentExpression curried:YES]];
                            currentExpression = nil;
                        } else {
                            state = stateError;
                        }
                        break;
                        
                    case '{':
                    case '}':
                    case '&':
                    case '$':
                    case '#':
                    case '^':
                    case '/':
                    case '<':
                    case '>':
                        // invalid as an identifier start
                        state = stateError;
                        break;
                        
                    default:
                        state = stateIdentifier;
                        
                        // enter stateIdentifier
                        identifierStart = i;
                        break;
                }
                break;
                
            case stateIdentifier:
                switch (c) {
                    case ' ':
                    case '\r':
                    case '\n':
                    case '\t': {
                        // leave stateIdentifier
                        NSString *identifier = [string substringWithRange:(NSRange){ .location = identifierStart, .length = i - identifierStart }];
                        if (currentExpression) {
                            currentExpression = [GRMustacheScopedExpression expressionWithBaseExpression:currentExpression identifier:identifier];
                        } else {
                            currentExpression = [GRMustacheIdentifierExpression expressionWithIdentifier:identifier];
                        }
                        
                        state = stateIdentifierDone;
                    } break;
                        
                    case '.': {
                        // leave stateIdentifier
                        NSString *identifier = [string substringWithRange:(NSRange){ .location = identifierStart, .length = i - identifierStart }];
                        if (currentExpression) {
                            currentExpression = [GRMustacheScopedExpression expressionWithBaseExpression:currentExpression identifier:identifier];
                        } else {
                            currentExpression = [GRMustacheIdentifierExpression expressionWithIdentifier:identifier];
                        }
                        
                        state = stateWaitingForIdentifier;
                    } break;
                        
                    case '(': {
                        // leave stateIdentifier
                        NSString *identifier = [string substringWithRange:(NSRange){ .location = identifierStart, .length = i - identifierStart }];
                        if (currentExpression) {
                            currentExpression = [GRMustacheScopedExpression expressionWithBaseExpression:currentExpression identifier:identifier];
                        } else {
                            currentExpression = [GRMustacheIdentifierExpression expressionWithIdentifier:identifier];
                        }
                        
                        NSAssert(currentExpression, @"WTF expected currentExpression");
                        state = stateInitial;
                        [filterExpressionStack addObject:currentExpression];
                        currentExpression = nil;
                    } break;
                        
                    case ')': {
                        // leave stateIdentifier
                        NSString *identifier = [string substringWithRange:(NSRange){ .location = identifierStart, .length = i - identifierStart }];
                        if (currentExpression) {
                            currentExpression = [GRMustacheScopedExpression expressionWithBaseExpression:currentExpression identifier:identifier];
                        } else {
                            currentExpression = [GRMustacheIdentifierExpression expressionWithIdentifier:identifier];
                        }
                        
                        if (filterExpressionStack.count > 0) {
                            NSAssert(currentExpression, @"WTF expected currentExpression");
                            NSAssert(filterExpressionStack.count > 0, @"WTF expected non empty filterExpressionStack");
                            state = stateFilterDone;
                            GRMustacheExpression *filterExpression = [filterExpressionStack lastObject];
                            [filterExpressionStack removeLastObject];
                            currentExpression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:currentExpression curried:NO];
                        } else {
                            state = stateError;
                        }
                    } break;
                        
                    case ',': {
                        // leave stateIdentifier
                        NSString *identifier = [string substringWithRange:(NSRange){ .location = identifierStart, .length = i - identifierStart }];
                        if (currentExpression) {
                            currentExpression = [GRMustacheScopedExpression expressionWithBaseExpression:currentExpression identifier:identifier];
                        } else {
                            currentExpression = [GRMustacheIdentifierExpression expressionWithIdentifier:identifier];
                        }
                        
                        if (filterExpressionStack.count > 0) {
                            NSAssert(currentExpression, @"WTF expected currentExpression");
                            NSAssert(filterExpressionStack.count > 0, @"WTF expected non empty filterExpressionStack");
                            state = stateInitial;
                            GRMustacheExpression *filterExpression = [filterExpressionStack lastObject];
                            [filterExpressionStack removeLastObject];
                            [filterExpressionStack addObject:[GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:currentExpression curried:YES]];
                            currentExpression = nil;
                        } else {
                            state = stateError;
                        }
                    } break;
                        
                        
                    default:
                        break;
                }
                break;
                
            case stateWaitingForIdentifier:
                switch (c) {
                    case ' ':
                    case '\r':
                    case '\n':
                    case '\t':
                        state = stateError;
                        break;
                        
                    case '.':
                        state = stateError;
                        break;
                        
                    case '(':
                        state = stateError;
                        break;
                        
                    case ')':
                        state = stateError;
                        break;
                        
                    case ',':
                        state = stateError;
                        break;
                        
                    case '{':
                    case '}':
                    case '&':
                    case '$':
                    case '#':
                    case '^':
                    case '/':
                    case '<':
                    case '>':
                        // invalid as an identifier start
                        state = stateError;
                        break;
                        
                    default:
                        state = stateIdentifier;
                        
                        // enter stateIdentifier
                        identifierStart = i;
                        break;
                }
                break;
                
            case stateIdentifierDone:
                switch (c) {
                    case ' ':
                    case '\r':
                    case '\n':
                    case '\t':
                        break;
                        
                    case '.':
                        state = stateError;
                        break;
                        
                    case '(':
                        NSAssert(currentExpression, @"WTF expected currentExpression");
                        state = stateInitial;
                        [filterExpressionStack addObject:currentExpression];
                        currentExpression = nil;
                        break;
                        
                    case ')':
                        if (filterExpressionStack.count > 0) {
                            NSAssert(currentExpression, @"WTF expected currentExpression");
                            NSAssert(filterExpressionStack.count > 0, @"WTF expected non empty filterExpressionStack");
                            state = stateFilterDone;
                            GRMustacheExpression *filterExpression = [filterExpressionStack lastObject];
                            [filterExpressionStack removeLastObject];
                            currentExpression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:currentExpression curried:NO];
                        } else {
                            state = stateError;
                        }
                        break;
                        
                    case ',':
                        if (filterExpressionStack.count > 0) {
                            NSAssert(currentExpression, @"WTF expected currentExpression");
                            NSAssert(filterExpressionStack.count > 0, @"WTF expected non empty filterExpressionStack");
                            state = stateInitial;
                            GRMustacheExpression *filterExpression = [filterExpressionStack lastObject];
                            [filterExpressionStack removeLastObject];
                            [filterExpressionStack addObject:[GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:currentExpression curried:YES]];
                            currentExpression = nil;
                        } else {
                            state = stateError;
                        }
                        break;
                        
                    default:
                        state = stateError;
                        break;
                }
                break;
                
            case stateFilterDone:
                switch (c) {
                    case ' ':
                    case '\r':
                    case '\n':
                    case '\t':
                        break;
                        
                    case '.':
                        state = stateWaitingForIdentifier;
                        break;
                        
                    case '(':
                        NSAssert(currentExpression, @"WTF expected currentExpression");
                        state = stateInitial;
                        [filterExpressionStack addObject:currentExpression];
                        currentExpression = nil;
                        break;
                        
                    case ')':
                        if (filterExpressionStack.count > 0) {
                            NSAssert(currentExpression, @"WTF expected currentExpression");
                            NSAssert(filterExpressionStack.count > 0, @"WTF expected non empty filterExpressionStack");
                            state = stateFilterDone;
                            GRMustacheExpression *filterExpression = [filterExpressionStack lastObject];
                            [filterExpressionStack removeLastObject];
                            currentExpression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:currentExpression curried:NO];
                        } else {
                            state = stateError;
                        }
                        break;
                        
                    case ',':
                        if (filterExpressionStack.count > 0) {
                            NSAssert(currentExpression, @"WTF expected currentExpression");
                            NSAssert(filterExpressionStack.count > 0, @"WTF expected non empty filterExpressionStack");
                            state = stateInitial;
                            GRMustacheExpression *filterExpression = [filterExpressionStack lastObject];
                            [filterExpressionStack removeLastObject];
                            [filterExpressionStack addObject:[GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:currentExpression curried:YES]];
                            currentExpression = nil;
                        } else {
                            state = stateError;
                        }
                        break;
                        
                    default:
                        state = stateError;
                        break;
                }
                break;
            default:
                NSAssert(NO, @"WTF unexpected state");
                break;
        }
    }
    
    
    // EOF
    
    switch (state) {
        case stateInitial:
            if (filterExpressionStack.count == 0) {
                state = stateEmpty;
            } else {
                state = stateError;
            }
            break;
            
        case stateLeadingDot:
            if (filterExpressionStack.count == 0) {
                NSAssert(currentExpression, @"WTF expected currentExpression");
                validExpression = currentExpression;
                state = stateValid;
            } else {
                state = stateError;
            }
            break;
            
        case stateIdentifier: {
            // leave stateIdentifier
            NSString *identifier = [string substringFromIndex:identifierStart];
            if (currentExpression) {
                currentExpression = [GRMustacheScopedExpression expressionWithBaseExpression:currentExpression identifier:identifier];
            } else {
                currentExpression = [GRMustacheIdentifierExpression expressionWithIdentifier:identifier];
            }
            
            if (filterExpressionStack.count == 0) {
                NSAssert(currentExpression, @"WTF expected currentExpression");
                validExpression = currentExpression;
                state = stateValid;
            } else {
                state = stateError;
            }
        } break;
            
        case stateWaitingForIdentifier:
            state = stateError;
            break;
            
        case stateIdentifierDone:
            if (filterExpressionStack.count == 0) {
                NSAssert(currentExpression, @"WTF expected currentExpression");
                validExpression = currentExpression;
                state = stateValid;
            } else {
                state = stateError;
            }
            break;
            
        case stateFilterDone:
            if (filterExpressionStack.count == 0) {
                NSAssert(currentExpression, @"WTF expected currentExpression");
                validExpression = currentExpression;
                state = stateValid;
            } else {
                state = stateError;
            }
            break;
            
        case stateError:
            break;
            
        default:
            NSAssert(NO, @"WTF unexpected state");
            break;
    }
    
    
    // End
    
    switch (state) {
        case stateEmpty:
            if (empty != NULL) {
                *empty = YES;
            }
            if (error != NULL) {
                *error = [NSError errorWithDomain:GRMustacheErrorDomain code:GRMustacheErrorCodeParseError userInfo:[NSDictionary dictionaryWithObject:@"Missing expression" forKey:NSLocalizedDescriptionKey]];
            }
            return nil;
            
        case stateError:
            if (empty != NULL) {
                *empty = NO;
            }
            if (error != NULL) {
                *error = [NSError errorWithDomain:GRMustacheErrorDomain code:GRMustacheErrorCodeParseError userInfo:[NSDictionary dictionaryWithObject:@"Invalid expression" forKey:NSLocalizedDescriptionKey]];
            }
            return nil;
            
        case stateValid:
            NSAssert(validExpression, @"WTF expected validExpression");
            return validExpression;
            
        default:
            NSAssert(NO, @"WTF unespected state");
            break;
    }
    
    return nil;
}

@end
