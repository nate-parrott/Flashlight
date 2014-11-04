//
//  ZZStandardDecryptInputStream.mm
//  zipzap
//
//  Created by Daniel Cohen Gindi on 12/29/13.
//
//

#import "ZZError.h"
#import "ZZStandardDecryptInputStream.h"
#import "ZZStandardCryptoEngine.h"

@implementation ZZStandardDecryptInputStream
{
	NSInputStream* _upstream;
	NSStreamStatus _status;
	ZZStandardCryptoEngine _crypto;
}

- (id)initWithStream:(NSInputStream*)upstream
			password:(NSString*)password
			  header:(uint8_t*)header
			   check:(uint16_t)check
			 version:(uint8_t)version
			   error:(out NSError**)error
{
	if ((self = [super init]))
	{
		_upstream = upstream;
		_status = NSStreamStatusNotOpen;

		_crypto.initKeys((unsigned char*)password.UTF8String);

		bool checkTwoBytes = version < 20;

		for (int i = 0; i < 12; i++)
		{
			uint8_t result = header[i] ^ _crypto.decryptByte();
			_crypto.updateKeys(result);

			// check against decryption result
			BOOL fail = NO;
			switch (i)
			{
				case 10:
					if (checkTwoBytes)
						// check low byte
						fail = result != (check & 0xFF);
					break;
				case 11:
					// check high byte
					fail = result != (check >> 8);
					break;
			}
			if (fail)
				return ZZRaiseErrorNil(error, ZZWrongPassword, @{});
		}
	}
	return self;
}

- (NSStreamStatus)streamStatus
{
	return _status;
}

- (NSError*)streamError
{
	return nil;
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
	
	for (NSInteger i = 0; i < bytesRead; i++)
	{
		unsigned char val = buffer[i] & 0xff;
		val = (val ^ _crypto.decryptByte()) & 0xff;
		_crypto.updateKeys(val);
		buffer[i] = val;
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

@end
