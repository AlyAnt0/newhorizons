import websocket
import threading
import packets_pb2 as packets
import traceback


def Position_to_string(msg):
    x = f"x: {msg.x}"
    y = f"y: {msg.y}"
    return f"Position{{ {x}, {y} }}"


def Direction_to_string(msg):
    if msg == packets.Direction.NORTH:
        return "NORTH"
    if msg == packets.Direction.NORTH_EAST:
        return "NORTH_EAST"
    if msg == packets.Direction.EAST:
        return "EAST"
    if msg == packets.Direction.SOUTH_EAST:
        return "SOUTH_EAST"
    if msg == packets.Direction.SOUTH:
        return "SOUTH"
    if msg == packets.Direction.SOUTH_WEST:
        return "SOUTH_WEST"
    if msg == packets.Direction.WEST:
        return "WEST"
    if msg == packets.Direction.NORTH_WEST:
        return "NORTH_WEST"
    return "???"


def JoinedRoom_to_string(msg):
    userName = f"userName: '{msg.userName}'"
    userID = f"userID: {msg.userID}"
    roomID = f"roomID: {msg.roomID}"
    position = f"position: {Position_to_string(msg.position)}"
    return f"JoinedRoom{{ {userName}, {userID}, {roomID}, {position} }}"


def LeftRoom_to_string(msg):
    userID = f"userID: {msg.userID}"
    roomID = f"roomID: {msg.roomID}"
    return f"LeftRoom{{ {userID}, {roomID} }}"


def ReceivedMessage_to_string(msg):
    userID = f"userID: {msg.userID}"
    content = f"content: '{msg.content}'"
    roomID = f"roomID: {msg.roomID}"
    return f"ReceivedMessage{{ {userID}, {content}, {roomID} }}"


def BeginAction_to_string(msg):
    if msg.actionType == packets.ActionType.IDLE:
        actionType = "actionType: IDLE"
        direction = f"direction: {Direction_to_string(msg.direction)}"
        return f"BeginAction{{ {actionType}, {direction} }}"
    if msg.actionType == packets.ActionType.DANCING:
        actionType = "actionType: DANCING"
        return f"BeginAction{{ {actionType} }}"
    if msg.actionType == packets.ActionType.SITTING:
        actionType = "actionType: SITTING"
        direction = f"direction: {Direction_to_string(msg.direction)}"
        return f"BeginAction{{ {actionType}, {direction} }}"
    if msg.actionType == packets.ActionType.MOVING:
        actionType = "actionType: MOVING"
        position = f"position: {Position_to_string(msg.position)}"
        return f"BeginAction{{ {actionType}, {position} }}"
    return "???"


def ReceivedAction_to_string(msg):
    userID = f"userID: {msg.userID}"
    action = f"action: {BeginAction_to_string(msg.action)}"
    roomID = f"roomID: {msg.roomID}"
    return f"ReceivedMessage{{ {userID}, {action}, {roomID} }}"


def on_message(ws, msg):
    # Deserialize incomming
    message = packets.Message()
    message.ParseFromString(msg)
    #print('Message', message)
    #print('MessageType', message.messageType)

    # Output message
    if message.messageType == packets.MessageType.JOINED_ROOM:
        joinedRoom = message.joinedRoom
        print(f"\n[ws] {JoinedRoom_to_string(joinedRoom)}",
              end='\n> ')
        return
    if message.messageType == packets.MessageType.LEFT_ROOM:
        leftRoom = message.leftRoom
        print(f"\n[ws] {LeftRoom_to_string(leftRoom)}",
              end='\n> ')
        return
    if message.messageType == packets.MessageType.RECEIVED_MESSAGE:
        receivedMessage = message.receivedMessage
        print(f"\n[ws] {ReceivedMessage_to_string(receivedMessage)}",
              end='\n> ')
        return
    if message.messageType == packets.MessageType.RECEIVED_ACTION:
        receivedAction = message.receivedAction
        print(f"\n[ws] {ReceivedAction_to_string(receivedAction)}",
              end='\n> ')
        return

    print(f"\n[ws] Unknown message type '{message.messageType}'.",
          end='\n> ')


def on_error(ws, error):
    try:
        raise error
    except:
        traceback.print_exc()


def on_close(ws, status_code, msg):
    print(f"Connection closed. Code: {status_code}, Message: {msg}")


def on_open(ws):
    # Start a thread to handle user input
    threading.Thread(target=handle_user_input, args=(ws,), daemon=True).start()


def handle_Login():
    name = input("name > ")
    login = packets.Login(name=name)
    return login


def handle_Position():
    x = float(input("x > "))
    y = float(input("y > "))
    position = packets.Position(x=x, y=y)
    return position


def handle_Direction():
    direction = input("direction > ")
    if direction == "NORTH":
        return packets.Direction.NORTH
    if direction == "NORTH_EAST":
        return packets.Direction.NORTH_EAST
    if direction == "EAST":
        return packets.Direction.EAST
    if direction == "SOUTH_EAST":
        return packets.Direction.SOUTH_EAST
    if direction == "SOUTH":
        return packets.Direction.SOUTH
    if direction == "SOUTH_WEST":
        return packets.Direction.SOUTH_WEST
    if direction == "WEST":
        return packets.Direction.WEST
    if direction == "NORTH_WEST":
        return packets.Direction.NORTH_WEST

    return None


def handle_RoomID():
    id = int(input("roomID > "))
    if id in [packets.RoomID.TOWN]:
        return id
    return None


def handle_JoinRoom():
    roomID = handle_RoomID()
    if roomID is None:
        return None
    joinRoom = packets.JoinRoom(roomID=roomID)
    joinRoom.position.CopyFrom(handle_Position())
    return joinRoom


def handle_SendMessage():
    content = input("content > ")
    sendMessage = packets.SendMessage(content=content)
    return sendMessage


def handle_ActionType():
    actionType = input("actionType > ")
    if actionType == "IDLE":
        return packets.ActionType.IDLE
    if actionType == "DANCING":
        return packets.ActionType.DANCING
    if actionType == "SITTING":
        return packets.ActionType.SITTING
    if actionType == "MOVING":
        return packets.ActionType.MOVING

    return None


def handle_BeginAction():
    actionType = handle_ActionType()
    if actionType is None:
        return None

    if actionType == packets.ActionType.IDLE:
        direction = handle_Direction()
        if direction is None:
            return None

        beginAction = packets.BeginAction()
        beginAction.actionType = actionType
        beginAction.direction = direction
        return beginAction

    if actionType == packets.ActionType.DANCING:
        beginAction = packets.BeginAction()
        beginAction.actionType = actionType
        return beginAction

    if actionType == packets.ActionType.SITTING:
        direction = handle_Direction()
        if direction is None:
            return None

        beginAction = packets.BeginAction()
        beginAction.actionType = actionType
        beginAction.direction = direction
        return beginAction

    if actionType == packets.ActionType.MOVING:
        position = handle_Position()

        beginAction = packets.BeginAction()
        beginAction.actionType = actionType
        beginAction.position.CopyFrom(position)
        return beginAction

    return None


def send_message(ws, message):
    serialized = message.SerializeToString()
    ws.send(serialized)


def handle_user_input(ws):
    while True:
        command = input("message > ")
        if command == "Login":
            login = handle_Login()
            if login:
                message = packets.Message()
                message.messageType = packets.MessageType.LOGIN
                message.login.CopyFrom(login)
                send_message(ws, message)
            continue
        if command == "JoinRoom":
            joinRoom = handle_JoinRoom()
            if joinRoom:
                message = packets.Message()
                message.messageType = packets.MessageType.JOIN_ROOM
                message.joinRoom.CopyFrom(joinRoom)
                send_message(ws, message)
            continue
        if command == "SendMessage":
            sendMessage = handle_SendMessage()
            if sendMessage:
                message = packets.Message()
                message.messageType = packets.MessageType.SEND_MESSAGE
                message.sendMessage.CopyFrom(sendMessage)
                send_message(ws, message)
            continue
        if command == "BeginAction":
            beginAction = handle_BeginAction()
            if beginAction:
                message = packets.Message()
                message.messageType = packets.MessageType.BEGIN_ACTION
                message.beginAction.CopyFrom(beginAction)
                send_message(ws, message)
            continue
        print(f"Unknown command: '{command}'")


def main():
    ws = websocket.WebSocketApp("ws://localhost:9999/ws",
                                on_open=on_open,
                                on_message=on_message,
                                on_error=on_error,
                                on_close=on_close)
    ws.run_forever()


if __name__ == "__main__":
    main()
