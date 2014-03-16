#include <iostream>
#include <vector>
#include <gmpxx.h>
#include <fstream>

using namespace std;

struct Key
{
    string id;
    mpz_class modulus;
};

int main(int argc, char** argv)
{
    vector<Key> keys;
    string line;

    if(argc < 2 || (argc == 2 && (string(argv[1]) == "-h" || string(argv[1]) == "--help")))
    {
        cout << "usage: ./gcd [-h] FILE..." << endl << endl;
        cout << "Compute the gcd of each pair of keys contained in the given files" << endl;
        cout << "to try to factor some keys." << endl << endl;
        cout << "arguments:" << endl;
        cout << "  FILE   A dump of GPG RSA keys" << endl;
        return 0;
    }

    /* load keys */
    cout << "loading keys..." << endl;

    for(int i = 1; i < argc; i++)
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

    /* gcd */
    mpz_class one(1);
    for(unsigned int i = 0; i < keys.size(); i++)
    {
        const mpz_class& n1 = keys[i].modulus;

        for(unsigned int j = i + 1; j < keys.size(); j++)
        {
            mpz_class gcd;
            mpz_gcd (gcd.get_mpz_t(), n1.get_mpz_t(), keys[j].modulus.get_mpz_t());

            if(gcd != one)
            {
                cout << "pub      " << keys[i].id << endl;
                cout << "factor   " << gcd << endl;
                cout << "pub      " << keys[j].id << endl;
                cout << "factor   " << gcd << endl;
            }
        }

        cout << (i+1) << " keys done" << endl;
    }

    return 0;
}
