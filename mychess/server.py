import socket,threading,json,select,sys
import multiprocessing
import queue
from Libryclass import JSONObject
from Libryclass import Room

server = socket.socket(socket.AF_INET,socket.SOCK_STREAM)

server.setblocking(0)

server.setsockopt(socket.SOL_SOCKET,socket.SO_REUSEADDR,1)

server.bind(("127.0.0.1",8080))

server.listen(5)

inputs = [server]

outputs = []

messageQueues={}

hall = []

for index in range(2):
    room = Room(index)
    hall.append(room)

def getJsonStrforTypeOne(hall):
    print("hall[1] %s" % hall[1].attrbutes['people'])
    print("hall[0] %s" % hall[0].attrbutes['people'])
    data={
        "type": 1,
        "roompeople1": hall[0].attrbutes['people'],
        "roomstatus1": hall[0].attrbutes['status'],
        "roompeople2": hall[1].attrbutes['people'],
        "roomstatus2": hall[1].attrbutes['status']
    }
    return json.dumps(data)

def receivedTypeFour(hall,data,sock):
    index = int(data.roomindex)
    print("room number %d" % index)
    if data.action == 'enter':
        hall[index].attrbutes['people']+=1
        hall[index].sithere(sock)
        if hall[index].isfull():
            hall[index].roomIsFull()
        else:
            hall[index].roomIsWait()
    elif data.action == 'leave':
        hall[index].peopleLeave()
        hall[index].leavehere(sock)
        if hall[index].isEmpty():
            hall[index].roomIsEmpty()
        else:
            hall[index].roomIsWait()


'''
def tcplink(sock,addr):
    print ("accept a new connection from %s" % (addr,))
    while True:
        jsonData = sock.recv(1024)
        if not jsonData:
            break
        data = json.loads(jsonData.decode('utf-8'),object_hook=JSONObject)
        if data.type == '1':
            print("Kan ")
            json_str = getJsonStrforTypeOne(hall)
            sock.send((b"%s" % json_str.encode('utf-8')))
        elif data.type == '2':
            print("Yao ")
        elif data.type == '3':
            print("The connection is good")
        else:
            print("invalid connection")
        print ("receve %s" % jsonData.decode('utf-8'))
        #sock.send((b"hello:%s" % jsonData.decode('utf-8').encode('utf-8')))
    sock.close()
    print ("connection close")


print ("wait for connection...")

while True:
    sock, addr = s.accept()
    t = threading.Thread(target=tcplink,args=(sock,addr))
    t.start()
'''

print("wait for connection...")
while True:
    readable, writeable, exceptional = select.select(inputs,outputs,inputs)

    for s in readable:
        if s is server:
            client,clientAddr = s.accept()
            print ("accept a new connection from %s" % (clientAddr,))
            client.setblocking(0)
            inputs.append(client)
            messageQueues[client] = multiprocessing.Queue()
        else:
            jsonData = s.recv(1024)
            if jsonData:
                data = json.loads(jsonData.decode('utf-8'),object_hook=JSONObject)
                if data.type == '1':
                    #print("Kan ")
                    json_str = getJsonStrforTypeOne(hall)
                    messageQueues[s].put(json_str)
                    if s not in outputs:
                        outputs.append(s)
                    #sock.send((b"%s" % json_str.encode('utf-8')))
                elif data.type == '2':
                    print("Yao ")
                elif data.type == '3':
                    print("The connection is good")
                elif data.type == '4':
                    print("4")
                    receivedTypeFour(hall,data,s)
                else:
                    print("invalid connection")
            else:
                if s in outputs:
                    outputs.remove(s)

                for index in range(2):
                    hall[index].RemoveSocketIfExit(s)

                inputs.remove(s)
                s.close()
                del messageQueues[s]

        for s in writeable:
            try:
                message = messageQueues[s].get_nowait()
            except queue.Empty:
                outputs.remove(s)
            except KeyError:
                pass
            else:
                s.send((b"%s" % message.encode('utf-8')))

        for s in exceptional:
            inputs.remove(s)
            if s in outputs:
                outputs.remove(s)

            for index in range(2):
                hall[index].RemoveSocketIfExit(s)
            s.close()
            del messageQueues[s]
