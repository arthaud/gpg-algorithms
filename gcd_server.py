#!/bin/env python3
from datetime import datetime
import argparse
import socket
import select

def debug(message):
    print('[%s] %s' % (datetime.now().strftime('%d-%m-%Y %H:%M:%S'), message))

def run(host, port, block_size, file):
    index = 0
    finish = False
    logfile = open(file, 'a')
    clients = []
    addresses = {}

    # socket
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((host, port))
    server.listen(5)

    debug('listening on %s:%s' % (host if host else '*', port))

    while server:
        readable, writable, exceptional = select.select(
            clients + [server], # input
            [], # output
            [server]) # error

        for s in readable:
            if s is server and not finish: # incoming connection
                client, address = server.accept()
                client.setblocking(False)

                clients.append(client)
                addresses[client] = address
                debug('%s:%s connected' % (address[0], address[1]))

                debug('sending work %s - %s to %s:%s' % (index, index+block_size-1, address[0], address[1]))
                msg = '%s %s\n' % (index, block_size)
                client.send(msg.encode('latin1'))
                index += block_size
            else: # client
                data = s.recv(4096)
                if data:
                    msg = data.strip().decode('latin1')

                    if msg == 'end':
                        finish = True
                        debug('%s:%s announced the end !' % addresses[s])
                    elif msg.startswith('factor'):
                        debug('%s:%s found a factor !' % addresses[s])
                        logfile.write(msg + '\n')
                        logfile.flush()
                    elif msg != 'done':
                        debug('error: bad message from %s:%s, exiting...' % addresses[s])

                        for client in clients:
                            client.close()

                        server.close()
                        logfile.close()
                        return

                    if msg in ('end', 'done'):
                        if not finish:
                            debug('sending work %s - %s to %s:%s' % (index, index+block_size-1, addresses[s][0], addresses[s][1]))
                            msg = '%s %s\n' % (index, block_size)
                            s.send(msg.encode('latin1'))
                            index += block_size
                        else:
                            debug('closing connection with %s:%s' % addresses[s])
                            clients.remove(s)
                            s.close()

                            if not clients:
                                server.close()
                                logfile.close()
                                debug('success ! exiting...')
                                return
                else:
                    debug('warning: %s:%s disconnected' % addresses[s])
                    clients.remove(s)
                    s.close()

        if exceptional:
            debug('exceptional socket, exiting...')

            for client in clients:
                client.close()

            server.close()
            logfile.close()
            return

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='A server for distributed computing of gcd of each pair of keys')
    parser.add_argument('--host', help='The server host', default='')
    parser.add_argument('-b', '--block-size', type=int, help='The block size', default=100)
    parser.add_argument('port', type=int, help='The server port')
    parser.add_argument('file', help='The output log file')
    args = parser.parse_args()

    run(args.host, args.port, args.block_size, args.file)
