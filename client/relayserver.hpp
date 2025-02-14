#ifndef RELAYSERVER_H
#define RELAYSERVER_H

class RelayServer {
public:
//    virtual void send_to_client(char * data, int len) {
//
//    }
    virtual ~RelayServer() = default;
    virtual void test() = 0;
    virtual void send_to_client(char * data, int len) = 0;
};

#endif