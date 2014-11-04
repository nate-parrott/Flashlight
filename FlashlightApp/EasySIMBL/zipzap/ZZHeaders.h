//
//  ZZHeaders.h
//  zipzap
//
//  Created by Glen Low on 6/10/12.
//  Copyright (c) 2012, Pixelglow Software. All rights reserved.
//

#include <stdint.h>
#include "ZZConstants.h"

enum class ZZCompressionMethod : uint16_t
{
	stored = 0,
	deflated = 8
};

enum class ZZFileAttributeCompatibility : uint8_t
{
	msdos = 0,
	unix = 3,
    ntfs = 10
};

enum class ZZMSDOSAttributes : uint8_t
{
	readonly = 1 << 0,
	hidden = 1 << 1,
    system = 1 << 2,
	volume = 1 << 3,
	subdirectory = 1 << 4,
	archive = 1 << 5
};

enum class ZZGeneralPurposeBitFlag: uint16_t
{
	none = 0,
	encrypted = 1 << 0,
	normalCompression = 0,
	maximumCompression = 1 << 1,
	fastCompression = 1 << 2,
	superFastCompression = (1 << 1) | (1 << 2),
	sizeInDataDescriptor = 1 << 3,
	encryptionStrong = 1 << 6,
	fileNameUTF8Encoded = 1 << 11
};

inline ZZGeneralPurposeBitFlag operator|(ZZGeneralPurposeBitFlag lhs, ZZGeneralPurposeBitFlag rhs)
{
	return static_cast<ZZGeneralPurposeBitFlag>(static_cast<uint16_t>(lhs) | static_cast<uint16_t>(rhs));
}

inline ZZGeneralPurposeBitFlag operator&(ZZGeneralPurposeBitFlag lhs, ZZGeneralPurposeBitFlag rhs)
{
	return static_cast<ZZGeneralPurposeBitFlag>(static_cast<uint16_t>(lhs) & static_cast<uint16_t>(rhs));
}

#pragma pack(1)

struct ZZExtraField
{
	uint16_t headerID;
	uint16_t dataSize;
	
    ZZExtraField *nextExtraField()
    {
		return reinterpret_cast<ZZExtraField*>(((uint8_t*)this) + sizeof(ZZExtraField) + dataSize);
    }
};

struct ZZWinZipAESExtraField: public ZZExtraField
{
	uint16_t versionNumber;
	uint8_t vendorId[2]; // For WinZip, should always be AE
    ZZAESEncryptionStrength encryptionStrength;
    ZZCompressionMethod compressionMethod;
    
	static const uint16_t head = 0x9901;
    
	static const uint16_t version_AE1 = 0x0001;
	static const uint16_t version_AE2 = 0x0002;
};

inline size_t getSaltLength(ZZAESEncryptionStrength encryptionStrength)
{
	switch (encryptionStrength)
	{
		case ZZAESEncryptionStrength128:
			return 8;
		case ZZAESEncryptionStrength192:
			return 12;
		case ZZAESEncryptionStrength256:
			return 16;
		default:
			return -1;
	}
}

inline size_t getKeyLength(ZZAESEncryptionStrength encryptionStrength)
{
	switch (encryptionStrength)
	{
		case ZZAESEncryptionStrength128:
			return 16;
		case ZZAESEncryptionStrength192:
			return 24;
		case ZZAESEncryptionStrength256:
			return 32;
		default:
			return -1;
	}
}

inline size_t getMacLength(ZZAESEncryptionStrength encryptionStrength)
{
	switch (encryptionStrength)
	{
		case ZZAESEncryptionStrength128:
			return 16;
		case ZZAESEncryptionStrength192:
			return 24;
		case ZZAESEncryptionStrength256:
			return 32;
		default:
			return -1;
	}
}


struct ZZCentralFileHeader
{
	uint32_t signature;
	uint8_t versionMadeBy;
	ZZFileAttributeCompatibility fileAttributeCompatibility;
	uint16_t versionNeededToExtract;
	ZZGeneralPurposeBitFlag generalPurposeBitFlag;
	ZZCompressionMethod compressionMethod;
	uint16_t lastModFileTime;
	uint16_t lastModFileDate;
	uint32_t crc32;
	uint32_t compressedSize;
	uint32_t uncompressedSize;
	uint16_t fileNameLength;
	uint16_t extraFieldLength;
	uint16_t fileCommentLength;
	uint16_t diskNumberStart;
	uint16_t internalFileAttributes;
	uint32_t externalFileAttributes;
	uint32_t relativeOffsetOfLocalHeader;
	
	static const uint32_t sign = 0x02014b50;
	
	uint8_t* fileName()
	{
		return reinterpret_cast<uint8_t*>(this) + sizeof(*this);
	}
	
	ZZExtraField* firstExtraField()
	{
		return reinterpret_cast<ZZExtraField*>(fileName() + fileNameLength);
	}
	
	ZZExtraField* lastExtraField()
	{
		return reinterpret_cast<ZZExtraField*>(reinterpret_cast<uint8_t*>(firstExtraField()) + extraFieldLength);
	}
	
	uint8_t* fileComment()
	{
		return reinterpret_cast<uint8_t*>(lastExtraField());
	}
			
	ZZCentralFileHeader* nextCentralFileHeader()
	{
		return reinterpret_cast<ZZCentralFileHeader*>(fileComment() + fileCommentLength);
	}
	
	template <typename T> T* extraField()
	{
		for (auto nextField = firstExtraField(), lastField = lastExtraField(); nextField < lastField; nextField = nextField->nextExtraField())
			if (nextField->headerID == T::head)
				// ASSUME: T is a subclass of ZZExtraField
				return static_cast<T*>(nextField);
		return NULL;
	}
};

struct ZZDataDescriptor
{
	uint32_t signature;
	uint32_t crc32;
	uint32_t compressedSize;
	uint32_t uncompressedSize;

	static const uint32_t sign = 0x08074b50;
};

struct ZZLocalFileHeader
{
	uint32_t signature;
	uint16_t versionNeededToExtract;
	ZZGeneralPurposeBitFlag generalPurposeBitFlag;
	ZZCompressionMethod compressionMethod;
	uint16_t lastModFileTime;
	uint16_t lastModFileDate;
	uint32_t crc32;
	uint32_t compressedSize;
	uint32_t uncompressedSize;
	uint16_t fileNameLength;
	uint16_t extraFieldLength;
	
	static const uint32_t sign = 0x04034b50;
	
	uint8_t* fileName()
	{
		return reinterpret_cast<uint8_t*>(this) + sizeof(*this);
	}
	
	ZZExtraField* firstExtraField()
	{
		return reinterpret_cast<ZZExtraField*>(fileName() + fileNameLength);
	}
	
	ZZExtraField* lastExtraField()
	{
		return reinterpret_cast<ZZExtraField*>(reinterpret_cast<uint8_t*>(firstExtraField()) + extraFieldLength);
	}
	
	uint8_t* fileData()
	{
		return reinterpret_cast<uint8_t*>(lastExtraField());
	}
		
	ZZDataDescriptor* dataDescriptor(uint32_t compressedSize)
	{
		return reinterpret_cast<ZZDataDescriptor*>(fileData() + compressedSize);
	}
	
	ZZLocalFileHeader* nextLocalFileHeader(uint32_t compressedSize)
	{
		return reinterpret_cast<ZZLocalFileHeader*>(fileData()
													+ compressedSize
													+ ((generalPurposeBitFlag & ZZGeneralPurposeBitFlag::sizeInDataDescriptor) == ZZGeneralPurposeBitFlag::none ? 0 : sizeof(ZZDataDescriptor)));
	}
	
	template <typename T> T* extraField()
	{
		for (auto nextField = firstExtraField(), lastField = lastExtraField(); nextField < lastField; nextField = nextField->nextExtraField())
			if (nextField->headerID == T::head)
				// ASSUME: T is a subclass of ZZExtraField
				return static_cast<T*>(nextField);
		return NULL;
	}
};

struct ZZEndOfCentralDirectory
{
	uint32_t signature;
	uint16_t numberOfThisDisk;
	uint16_t numberOfTheDiskWithTheStartOfTheCentralDirectory;
	uint16_t totalNumberOfEntriesInTheCentralDirectoryOnThisDisk;
	uint16_t totalNumberOfEntriesInTheCentralDirectory;
	uint32_t sizeOfTheCentralDirectory;
	uint32_t offsetOfStartOfCentralDirectoryWithRespectToTheStartingDiskNumber;
	uint16_t zipFileCommentLength;
	
	static const uint32_t sign = 0x06054b50;
};

#pragma pack()

