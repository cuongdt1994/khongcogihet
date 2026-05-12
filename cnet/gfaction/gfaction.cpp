#include "gfactionserver.hpp"
#include "gproviderserver.hpp"
#include "gfactiondbclient.hpp"
#include "conf.h"
#include "log.h"
#include "thread.h"
#include <iostream>
#include <unistd.h>
#include "matcher.h"
#include "itimer.h"
#include "uniquenameclient.hpp"
#include "factiondb.h"
//#include <liblicense.h>
#include <beaktrace.h>
#include "luaman.hpp"

using namespace GNET;
int main(int argc, char *argv[])
{
	static const char * m_service = "gfaction";
	
//VM_BEGIN
	int m_result = 0;
//	Conf *license_conf = Conf::GetInstance("/home/license.conf");

//	if ( !LicenseInterfaces::Init(
//		license_conf->find("GLicenseClient", "address").c_str(), 
//		atoi(license_conf->find("GLicenseClient", "port").c_str()), 
//		license_conf->find("GLicenseClient", "login").c_str(), 
//		license_conf->find("GLicenseClient", "passwd").c_str(), 
//		m_service, 
//		m_result) 
//		)
	{
//		printf("LICENSE::START: ERR=%d \n", m_result);
//		kill(0, SIGUSR1);
	}
//VM_END
	
	SetupSignalHandler();
	
	if (argc != 2 || access(argv[1], R_OK) == -1)
	{
		printf("Compiled By Newester Entertainment\n");
		std::cerr << "Usage: " << argv[0] << " configurefile" << std::endl;
		exit(-1);
	}

//VM_BEGIN
	if (true)
	{
		LuaManager::GetInstance()->Init();
		IntervalTimer::StartTimer(500000);
	}
//VM_END
	
	
	bool is_central_faction = false;
	Conf *conf = Conf::GetInstance(argv[1]);
	Log::setprogname(m_service);
	{
		GFactionServer *manager = GFactionServer::GetInstance();
		manager->SetAccumulate(atoi(conf->find(manager->Identification(), "accumulate").c_str()));
		Protocol::Server(manager);
		std::string central_faction = conf->find(manager->Identification(), "is_central_faction");
		if(central_faction == "true") manager->SetCentralFaction(true);
		is_central_faction = manager->IsCentralFaction();

		if(Matcher::GetInstance()->Load(conf->find(manager->Identification(),"table_name").c_str(),
			"UCS2", conf->find(manager->Identification(),"name_charset").c_str(),
			conf->find(manager->Identification(), "table_charset").c_str()))
		{
			std::cerr<<"Cannot load table of sensitive words. check file ./filters."<<std::endl;
			Log::log(LOG_ERR,"Cannot load sensitive words, check %s", 
				conf->find(manager->Identification(),"table_name").c_str());
			exit(-1);
		}
	}

	{
		GProviderServer *manager = GProviderServer::GetInstance();
		//faction server的ID必须为101-200之间
		manager->SetProviderID(atoi(conf->find(manager->Identification(), "id").c_str()));
		if (manager->GetProviderID()<101 || manager->GetProviderID()>200) 
		{
			Log::log(LOG_ERR,"FactionProvider's id must be in range (101,200). Check .conf file.\n");
			exit(EXIT_FAILURE);
		}
		manager->SetAccumulate(atoi(conf->find(manager->Identification(), "accumulate").c_str()));
		Protocol::Server(manager);
	}
	{
		GFactionDBClient *manager = GFactionDBClient::GetInstance();
		manager->SetAccumulate(atoi(conf->find(manager->Identification(), "accumulate").c_str()));
		Protocol::Client(manager);
	}
	if(!is_central_faction)
	{
		UniqueNameClient* manager=UniqueNameClient::GetInstance();
		Protocol::Client(manager);
		Thread::HouseKeeper::AddTimerTask(new KeepAliveTask(30),30); 
	}
	
//VM_BEGIN
	if (true)
	{
		Thread::Pool::AddTask(new LuaTimer(1));
		Factiondb::GetInstance()->InitFactiondb();
		Thread::Pool::AddTask(PollIO::Task::GetInstance());
		Thread::Pool::Run();
	}
//VM_END
	
	return 0;
}

