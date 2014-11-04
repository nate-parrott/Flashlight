//
//  ZZDataProvider.h
//  zipzap
//
//  Created by Glen Low on 3/01/14.
//
//

#include <new>

class ZZDataProvider
{
public:
	static CGDataProviderRef create(NSInputStream*(^makeStream)())
	{
		// create the wrapper
		// NOTE: no libc++ runtime, so no operator new / delete; use malloc / free instead
		ZZDataProvider* dataProvider = new((ZZDataProvider*)malloc(sizeof(ZZDataProvider))) ZZDataProvider(makeStream);
		
		// trampoline C callbacks to C++ wrapper member functions
		CGDataProviderSequentialCallbacks dataProviderCallbacks =
		{
			0,
			[](void* info, void* buffer, size_t count) -> size_t
			{
				return reinterpret_cast<ZZDataProvider*>(info)->getBytes(buffer, count);
			},
			[](void* info, off_t count) -> off_t
			{
				return reinterpret_cast<ZZDataProvider*>(info)->skipForwardBytes(count);
			},
			[](void* info)
			{
				reinterpret_cast<ZZDataProvider*>(info)->rewind();
			},
			[](void* info)
			{
				reinterpret_cast<ZZDataProvider*>(info)->~ZZDataProvider();
				free(info);
			}
		};
		return CGDataProviderCreateSequential(dataProvider, &dataProviderCallbacks);
	}
	
private:
	ZZDataProvider(NSInputStream*(^makeStream)()): _makeStream(makeStream), _stream(nil)
	{
		// private to force creation on heap
	}

	~ZZDataProvider()
	{
		// private to force deallocation from heap
		if (_stream)
			[_stream close];
	}

	size_t getBytes (void* buffer, size_t count)
	{
		if (!_stream)
		{
			_stream = _makeStream();
			[_stream open];
		}
		
		// CoreGraphics likes full buffers, so we aim to please...
		size_t totalBytesRead = 0;
		while (totalBytesRead < count)
		{
			NSInteger bytesRead = [_stream read:(uint8_t*)buffer + totalBytesRead
									  maxLength:count - totalBytesRead];
			if (bytesRead > 0)
				totalBytesRead += bytesRead;
			else
				break;
		}
		return totalBytesRead;
	}
	
	off_t skipForwardBytes (off_t count)
	{
		if (!_stream)
		{
			_stream = _makeStream();
			[_stream open];
		}
		if (count > 0)
		{
			uint8_t skip[1024];
			
			// read in 1K at a time until byte count read
			uint64_t totalBytesRead = 0;
			while (totalBytesRead < count)
			{
				NSInteger bytesRead = [_stream read:skip
										  maxLength:(NSUInteger)MIN((uint64_t)sizeof(skip), count - totalBytesRead)];
				if (bytesRead > 0)
					totalBytesRead += bytesRead;
				else
					break;
			}
			return totalBytesRead;
		}
		else
			// can't skip backwards
			return 0;
	}
	
	void rewind ()
	{
		// streams cannot rewind by themselves
		// so we close the stream and the next get/skip will re-open it
		[_stream close];
		_stream = nil;
	}
	
	NSInputStream*(^_makeStream)();
	NSInputStream* _stream;
};
