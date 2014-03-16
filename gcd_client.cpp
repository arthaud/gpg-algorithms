#include <iostream>
#include <sstream>
#include <vector>
#include <gmpxx.h>
#include <fstream>
#include <SFML/Network.hpp>

using namespace std;
using namespace sf;

struct Key
{
    string id;
    mpz_class modulus;
};

int main(int argc, char** argv)
{
    string line;
    vector<Key> keys;
    mpz_class one(1);

    TcpSocket socket;
    int port;

    const char done_msg[] = "done\n";
    const char end_msg[] = "end\n";

    if(argc < 4 || (argc == 2 && (string(argv[1]) == "-h" || string(argv[1]) == "--help")))
    {
        cout << "usage: ./gcd_client [-h] HOST PORT FILE..." << endl << endl;
        cout << "A client for distributed computing of gcd of each pair of keys" << endl << endl;
        cout << "arguments:" << endl;
        cout << "  HOST   The server host" << endl;
        cout << "  PORT   The server port" << endl;
        cout << "  FILE   A dump of GPG RSA keys" << endl;
        return 0;
    }

    /* load keys */
    cout << "loading keys..." << endl;

    for(int i = 3; i < argc; i++)
    {
        fstream in(argv[i]);

        while(getline(in, line))
        {
            int pos = line.find(' ');
            string id = line.substr(0, pos);
            mpz_class modulus = mpz_class(line.substr(pos+1), 16);

            Key k = { id, modulus };
            keys.push_back(k);
        }

        in.close();
    }

    cout << "keys loaded (" << keys.size() << " keys)" << endl;

    /* connect to the server */
    port = atoi(argv[2]);

    if(port == 0)
    {
        cerr << "gcd_client: error: can't convert " << argv[2] << " to integer" << endl;
        return 1;
    }

    if(socket.connect(argv[1], port) != Socket::Done)
    {
        cerr << "gcd_client: error: can't connect to " << argv[1] << ":" << port << endl;
        return 1;
    }

    cout << "connected to " << argv[1] << ":" << port << endl;

    while(true)
    {
        /* get work */
        char in[1024];
        size_t received;
    
        if(socket.receive(in, sizeof(in), received) != Socket::Done)
        {
            cout << "disconnected by the server (no more works)" << endl;
            return 0;
        }

        in[received-1] = '\0';
        string order(in);
        int pos = order.find(' ');
        unsigned int index = atoi(order.substr(0, pos).c_str());
        unsigned int length = atoi(order.substr(pos+1).c_str());

        if(index >= keys.size() || length == 0)
        {
            cerr << "gcd_client: error: bad message from server" << endl;
            return 1;
        }

        cout << "received work (index=" << index << " length=" << length << ")" << endl;

        /* doing work */
        unsigned int max_index = min(static_cast<unsigned int>(keys.size()), index + length);
        for(unsigned int i = index; i < max_index; i++)
        {
            const mpz_class& n1 = keys[i].modulus;

            for(unsigned int j = i + 1; j < keys.size(); j++)
            {
                mpz_class gcd;
                mpz_gcd (gcd.get_mpz_t(), n1.get_mpz_t(), keys[j].modulus.get_mpz_t());

                if(gcd != one)
                {
                    /* send factor */
                    stringstream factor_msg;
                    factor_msg << "factor " << keys[i].id << " " << gcd << endl;
                    factor_msg << "factor " << keys[j].id << " " << gcd << endl;

                    cout << factor_msg.str();
                    if(socket.send(factor_msg.str().c_str(), sizeof(char) * factor_msg.str().size()) != Socket::Done)
                    {
                        cerr << "gcd_client: error: disconnected by the server" << endl;
                        return 1;
                    }
                }
            }
        }

        /* send result */
        const char* msg = (max_index == keys.size()) ? end_msg : done_msg;

        if(socket.send(msg, sizeof(char) * strlen(msg)) != Socket::Done)
        {
            cerr << "gcd_client: error: disconnected by the server" << endl;
            return 1;
        }
    }

    return 0;
}
