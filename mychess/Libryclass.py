class JSONObject:
    def __init__(self,d):
        self.__dict__ = d

class Room:

    def __init__(self,index):
        self.attrbutes = {
            "number": index,
            "status":'empty',
            "people": 0,
            "playerone":0,
            "playeroneFlag":False,
            "playertwo":0,
            "playertwoFlag":False
        }

    def peopleArrive(self):
        self.attrbutes['people'] += 1

    def peopleLeave(self):
        self.attrbutes['people'] -= 1

    def isfull(self):
        if self.attrbutes['people'] == 2:
            return True
        else:
            return False

    def isEmpty(self):
        if self.attrbutes['people'] == 0:
            return True
        else:
            return False

    def roomIsFull(self):
        self.attrbutes['status'] = 'full'

    def roomIsEmpty(self):
        self.attrbutes['status'] = 'empty'

    def roomIsWait(self):
        self.attrbutes['status'] = 'wait'

    def checkRoomStatus(self):
        return self.attrbutes['status']

    def RemoveSocketIfExit(self,sock):
        if self.attrbutes['playeroneFlag']:
            if self.attrbutes['playerone'] == sock:
                self.attrbutes['people']-=1
                self.attrbutes['playeroneFlag']=False
                self.attrbutes['playerone'] = 0
            else:
                pass
        else:
            pass
        if self.attrbutes['playertwoFlag']:
            if self.attrbutes['playertwo'] == sock:
                self.attrbutes['people']-=1
                self.attrbutes['playertwoFlag']=False
                self.attrbutes['playertwo']=0
            else:
                pass
        else:
            pass
        if self.attrbutes['people'] == 0:
            self.attrbutes['status'] = 'empty'
        elif self.attrbutes['people'] == 1:
            self.attrbutes['status'] = 'wait'
        elif self.attrbutes['people'] == 2:
            self.attrbutes['status'] = 'full'
        else:
            pass

    def sithere(self,sock):
        if not self.attrbutes['playeroneFlag']:
            self.attrbutes['playerone'] = sock
            self.attrbutes['playeroneFlag'] = True
        elif not self.attrbutes['playertwoFlag']:
            self.attrbutes['playertwo'] = sock
            self.attrbutes['playertwoFlag'] = True
        else:
            pass

    def leavehere(self,sock):
        if self.attrbutes['playeroneFlag']:
            if self.attrbutes['playerone'] == sock:
                self.attrbutes['playerone'] = 0
                self.attrbutes['playeroneFlag'] = False
            else:
                pass
        if self.attrbutes['playertwoFlag']:
            if self.attrbutes['playertwo'] == sock:
                self.attrbutes['playertwo'] = 0
                self.attrbutes['playertwoFlag'] = False
            else:
                pass
