// SWIG interface file for OpenVPN client

// enable director feature for OpenVPNClientBase virtual method callbacks
%module(directors="1") ovpncli
%feature("director") OpenVPNClient;
%feature("director") RelayServer;

%include "std_string.i" // for std::string typemaps
%include "std_vector.i"

%include "various.i"
%include "typemaps.i"

// Basic int typemap with descriptor
%typemap(directorin,descriptor="I") int "$input = (jint)$1;"
%typemap(directorin,descriptor="I") openvpn_io::detail::socket_type "$input = (jint)$1;"
%typemap(directorin,descriptor="I") asio::detail::socket_type "$input = (jint)$1;"

// ByteBuffer typemaps for all (char*, int) parameters
%typemap(jni) (char *data, int len) "jobject"
%typemap(jtype) (char *data, int len) "java.nio.ByteBuffer"
%typemap(jstype) (char *data, int len) "java.nio.ByteBuffer"
%typemap(javain) (char *data, int len) "$javainput"

%typemap(in) (char *data, int len) {
    $1 = (char *) JCALL1(GetDirectBufferAddress, jenv, $input);
    $2 = JCALL1(GetDirectBufferCapacity, jenv, $input);
}

// Director typemap for ByteBuffer
%typemap(directorin,descriptor="Ljava/nio/ByteBuffer;") (char *data, int len) {
$input = jenv->NewDirectByteBuffer($1, $2);
}

// Typemap for methods returning int
%typemap(directorout) int %{
$result = (int)$input;
%}

// Additional typemaps for other virtual methods
%typemap(directorin,descriptor="Z") bool "$input = (jboolean)$1;"
%typemap(directorout) bool %{
$result = $input;
%}

// String typemaps with descriptors
%typemap(directorin,descriptor="Ljava/lang/String;") std::string {
jstring js = jenv->NewStringUTF($1.c_str());
$input = js;
}

// top-level C++ implementation file
%{
#include "ovpncli.hpp"
#include "relayserver.hpp"
%}

%inline %{
void openvpn::ClientAPI::OpenVPNClient::send(char *data, int len) {
    sendRelay(data, len);
}

//void RelayServer::send_to_client(char *data, int len) {
//    // do nothing
//}
%}

#ifndef OPENVPN_PLATFORM_WIN
// simplify interface, not picked up automatically
%apply int { openvpn_io::detail::socket_type };
%apply int { asio::detail::socket_type };
#endif

// ignore these ClientAPI::OpenVPNClient bases
%ignore openvpn::ClientAPI::LogReceiver;
%ignore openvpn::ExternalTun::Factory;
%ignore openvpn::ExternalTransport::Factory;

// modify exported C++ class names to incorporate their enclosing namespace
%rename(ClientAPI_OpenVPNClient) OpenVPNClient;
%rename(ClientAPI_OpenVPNClientHelper) OpenVPNClientHelper;
%rename(ClientAPI_TunBuilderBase) TunBuilderBase;
%rename(ClientAPI_ExternalPKIBase) ExternalPKIBase;
%rename(ClientAPI_ServerEntry) ServerEntry;
%rename(ClientAPI_EvalConfig) EvalConfig;
%rename(ClientAPI_ProvideCreds) ProvideCreds;
%rename(ClientAPI_SessionToken) SessionToken;
%rename(ClientAPI_DynamicChallenge) DynamicChallenge;
%rename(ClientAPI_KeyValue) KeyValue;
%rename(ClientAPI_Config) Config;
%rename(ClientAPI_Event) Event;
%rename(ClientAPI_AppCustomControlMessageEvent) AppCustomControlMessageEvent;
%rename(ClientAPI_ConnectionInfo) ConnectionInfo;
%rename(ClientAPI_Status) Status;
%rename(ClientAPI_LogInfo) LogInfo;
%rename(ClientAPI_InterfaceStats) InterfaceStats;
%rename(ClientAPI_TransportStats) TransportStats;
%rename(ClientAPI_MergeConfig) MergeConfig;
%rename(ClientAPI_ExternalPKIRequestBase) ExternalPKIRequestBase;
%rename(ClientAPI_ExternalPKICertRequest) ExternalPKICertRequest;
%rename(ClientAPI_ExternalPKISignRequest) ExternalPKISignRequest;
%rename(ClientAPI_RemoteOverride) RemoteOverride;

// declare vectors
namespace std {
  %template(ClientAPI_ServerEntryVector) vector<openvpn::ClientAPI::ServerEntry>;
  %template(ClientAPI_LLVector) vector<long long>;
  %template(ClientAPI_StringVec) vector<string>;
};

// interface to be bridged between C++ and target language
%include "openvpn/pki/epkibase.hpp"
%include "openvpn/tun/builder/base.hpp"
%import  "openvpn/tun/extern/fw.hpp"     // ignored
%include "relayserver.hpp"
%import  "openvpn/transport/client/extern/fw.hpp"     // ignored
%include "ovpncli.hpp"