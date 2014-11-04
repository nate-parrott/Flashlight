//
//  ZZScopeGuard.h
//  zipzap
//
//  Created by Glen Low on 30/12/13.
//
//

class ZZScopeGuard
{
public:
	ZZScopeGuard(void(^exit)()): _exit(exit)
	{
	}
	
	~ZZScopeGuard()
	{
		_exit();
	}

private:
	void(^_exit)();
};
