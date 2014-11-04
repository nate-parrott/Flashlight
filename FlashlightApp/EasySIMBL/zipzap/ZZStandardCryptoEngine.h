//
//  ZZStandardCryptoEngine.h
//  zipzap
//
//  Created by Daniel Cohen Gindi on 12/29/13.
//
//

class ZZStandardCryptoEngine
{
public:
    ZZStandardCryptoEngine()
	{
	}
	
    void initKeys(unsigned char *password)
	{
		keys[0] = 305419896;
		keys[1] = 591751049;
		keys[2] = 878082192;
		while (*password)
		{
			updateKeys((*password) & 0xff);
			password++;
		}
	}

    void updateKeys(unsigned char charAt)
	{
		keys[0] = crc32(keys[0], charAt);
		keys[1] += keys[0] & 0xff;
		keys[1] = keys[1] * 134775813 + 1;
		keys[2] = crc32(keys[2], (unsigned char) (keys[1] >> 24));
	}

    int crc32(int oldCrc, unsigned char charAt)
	{
		return (((unsigned int)oldCrc >> 8) ^ CRC_TABLE[(oldCrc ^ charAt) & 0xff]);
	}

    unsigned char decryptByte()
	{
		int temp = keys[2] | 2;
		temp *= temp ^ 1;
		return (unsigned char) ((*((unsigned int *)&temp)) >> 8);
	}
    
private:
    int keys[3];
    static int CRC_TABLE[256];
	
};
