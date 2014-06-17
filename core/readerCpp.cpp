#include <string>
#include <iterator>
#include <iostream>
#include <algorithm>
#include <array>
#include <vector>
#include <iostream>
#include <thread>         // std::thread

using namespace std;

class splitstring : public string {
	vector<string> flds;
public:
	splitstring(string s) : string(s) { };
	vector<string>& split(char delim, int rep = 0) {
	if (!flds.empty()) flds.clear();  // empty vector if necessary
	string work = data();
	string buf = "";
	int i = 0;
	while (i < work.length()) {
		if (work[i] != delim)
			buf += work[i];
		else if (rep == 1) {
			flds.push_back(buf);
			buf = "";
		}
		else if (buf.length() > 0) {
			flds.push_back(buf);
			buf = "";
		}
		i++;
	}
	if (!buf.empty())
		flds.push_back(buf);
	return flds;
}
};

class myJob {
	public:
	string type = "";
	string domain = "";

	myJob() {}
	// create myJob from "type:domain"
	myJob(string json) {
		string token;
		splitstring s(json);
		vector<string> jsonTab = s.split(':');
		for (int i = 0; i < jsonTab.size(); i++) {
			token = jsonTab[i];
			if ( i==0 ) type = token;
			else if ( i==1 ) domain = token;
		}
	}
};

void runPerl(string type, string domain) {
	cout <<"run("<<type<<") = "<<domain <<" \n";
}

/**
* g++  -pthrd -std=c++11 readerCpp.cpp -o readerCpp && ./readerCpp
* 
* na wejsciu mamy JSON ktory przetwarzamy na tablice:
* [][type,domain], np. [domena, x.pl], [serwer, domena.pl]
*/
int main()
{
 // pobierz json
 // json to array
 string json = "serwer:x.pl;domena:y.pl";
   vector< myJob > myJobList;
	string token;
	splitstring s(json);
	vector<string> jsonTab = s.split(';');
	for (int i = 0; i < jsonTab.size(); i++) {
		myJobList.push_back( myJob(jsonTab[i]) );
	}

int t_ile = myJobList.size();
if ( t_ile == 0 ) { return 0; }
vector<thread> myThread;
for (int i=0; i < myJobList.size(); i++) {
	myThread.push_back( thread(runPerl, myJobList[i].type, myJobList[i].domain) );
}

for (int i=0; i < myThread.size(); i++) {
	myThread[i].join();
}

    cout << "ok";
	return 0;
}
