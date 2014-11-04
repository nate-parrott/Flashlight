//
//  ZZAESDecryptInputStream.mm
//  zipzap
//
//  Created by Daniel Cohen Gindi on 1/6/14.
//
//

#import <CommonCrypto/CommonCrypto.h>

#import "ZZAESDecryptInputStream.h"
#import "ZZHeaders.h"
#import "ZZError.h"

static const uint WINZIP_PBKDF2_ROUNDS = 1000;

@implementation ZZAESDecryptInputStream
{
	NSInputStream* _upstream;
	NSStreamStatus _status;
	
	uint32_t _counterNonce[4];
	uint8_t _keystream[16];
	NSUInteger _keystreamPos;
	
	CCCryptorRef _aes;
}

- (id)initWithStream:(NSInputStream*)upstream
			password:(NSString*)password
			  header:(uint8_t*)header
			strength:(ZZAESEncryptionStrength)strength
			   error:(out NSError**)error
{
	if ((self = [super init]))
	{
		_upstream = upstream;
		
		_counterNonce[0] = _counterNonce[1] = _counterNonce[2] = _counterNonce[3] = 0;
		_keystreamPos = sizeof(_keystream);
		
		size_t saltLength = getSaltLength(strength);
		size_t keyLength = getKeyLength(strength);
		size_t macLength = getMacLength(strength);
		size_t keyMacVerifierLength = keyLength + macLength + sizeof(uint16_t);
		
		uint8_t* headerSalt = header;
		uint16_t* headerVerifier = (uint16_t*)(header + saltLength);
		
		uint8_t derivedKeyMacVerifier[keyMacVerifierLength];
		uint8_t* derivedKey = derivedKeyMacVerifier;
		uint16_t* derivedVerifier = (uint16_t*)(derivedKeyMacVerifier + keyLength + macLength);
		
		// Should we use the Zip's filename encoding for the password? We have to figure that out...
		NSData* passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
		
		CCKeyDerivationPBKDF(kCCPBKDF2,
							 (char*)passwordData.bytes,
							 passwordData.length,
							 headerSalt,
							 saltLength,
							 kCCPRFHmacAlgSHA1,
							 WINZIP_PBKDF2_ROUNDS,
							 derivedKeyMacVerifier,
							 keyMacVerifierLength);
		
		// NSData *macKey = [NSData dataWithBytes:((char *)_key.bytes + keyLength) length:macLength]; // TODO: Use for authentication
		
		if (*derivedVerifier == *headerVerifier)
		{
			_status = NSStreamStatusNotOpen;

			CCCryptorCreate(kCCEncrypt,
							kCCAlgorithmAES,
							kCCOptionECBMode,
							derivedKey,
							keyLength,
							NULL,
							&_aes);
			
		}
		else
		{ // Wrong password
			_status = NSStreamStatusError;
			_aes = NULL;

			return ZZRaiseErrorNil(error, ZZWrongPassword, @{});
		}
	}
	return self;
}

- (NSStreamStatus)streamStatus
{
	return _status;
}

- (void)open
{
	[_upstream open];

	_status = NSStreamStatusOpen;
}

- (void)close
{
	[_upstream close];
	
	_status = NSStreamStatusClosed;
}

- (NSInteger)read:(uint8_t*)buffer maxLength:(NSUInteger)len
{
	NSInteger bytesRead = [_upstream read:buffer maxLength:len];
	
	// WinZip uses AES in CTR mode with 32-bit counter = 1, 2, 3... appended to nonce = 0
	
	for (NSInteger bufferIndex = 0; bufferIndex < bytesRead; ++bufferIndex, ++_keystreamPos)
	{
		// encrypt(next nonce counter, key) -> next keystream block
		if (_keystreamPos == sizeof(_keystream))
		{
			_keystreamPos = 0;
			++_counterNonce[0];

			size_t dataOutMoved = 0;
			CCCryptorUpdate(_aes,
							_counterNonce,
							sizeof(_counterNonce),
							_keystream,
							sizeof(_keystream),
							&dataOutMoved);
			
		}
		
		// keystream block XOR plaintext -> ciphertext
		buffer[bufferIndex] ^= _keystream[_keystreamPos];
	}
	
	return bytesRead;
}

- (BOOL)getBuffer:(uint8_t**)buffer length:(NSUInteger*)len
{
	return NO;
}

- (BOOL)hasBytesAvailable
{
	return YES;
}

- (void)dealloc
{
	if (_aes)
		CCCryptorRelease(_aes);
}

@end
