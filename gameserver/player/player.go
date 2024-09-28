package player

import (
    "gameserver/packets"
    "github.com/anthdm/hollywood/actor"
    "github.com/gorilla/websocket"
    "google.golang.org/protobuf/proto"
    "log"
)

type PlayerSession struct {
    userID      uint64
    username    string
    loggedIn    bool
    currentRoom packets.RoomID
    conn        *websocket.Conn
    ctx         *actor.Context
    serverPID   *actor.PID
}

func NewPlayerSession(serverPID *actor.PID, userID uint64, conn *websocket.Conn) actor.Producer {
    return func() actor.Receiver {
        return &PlayerSession{
            userID:      userID,
            loggedIn:    false,
            currentRoom: packets.RoomID_NONE,
            conn:        conn,
            serverPID:   serverPID,
        }
    }
}

func (s *PlayerSession) Receive(ctx *actor.Context) {
    switch msg := ctx.Message().(type) {
    case actor.Started:
        s.ctx = ctx
        go s.readLoop()
    case *packets.JoinedRoom:
        if (s.currentRoom == msg.GetRoomID()) { // Only if message is for the current room
            log.Println("Got message to pass on JoinedRoom to client.")
            s.sendJoinedRoom(msg)
        }
    case *packets.LeftRoom:
        if (s.currentRoom == msg.GetRoomID()) { // Only if message is for the current room
            log.Println("Got message to pass on LeftRoom to client.")
            s.sendLeftRoom(msg)
        }
    case *packets.ReceivedMessage:
        if (s.currentRoom == msg.GetRoomID()) { // Only if message is for the current room
            log.Println("Got message to pass on RecieivedMessage to client.")
            s.sendReceivedMessage(msg)
        }
    case *packets.ReceivedAction:
        if (s.currentRoom == msg.GetRoomID()) { // Only if message is for the current room
            log.Println("Got message to pass on ReceivedAction to client.")
            s.sendReceivedAction(msg)
        }
    default:
        log.Println("Unhandled player session message", msg)
    }
}

func (s *PlayerSession) marshalAndSendMessage(msg *packets.Message) {
    log.Println("Message", msg)
    messageData, err := proto.Marshal(msg)
    if err != nil {
        panic(err)
    }
    if err := s.conn.WriteMessage(websocket.BinaryMessage, messageData); err != nil {
        panic(err)
    }
}

func (s *PlayerSession) sendJoinedRoom(msg *packets.JoinedRoom) {
    s.marshalAndSendMessage(&packets.Message{
        MessageType: packets.MessageType_JOINED_ROOM,
        MessageData: &packets.Message_JoinedRoom{JoinedRoom: msg},
    })
}
func (s *PlayerSession) sendLeftRoom(msg *packets.LeftRoom) {
    s.marshalAndSendMessage(&packets.Message{
        MessageType: packets.MessageType_LEFT_ROOM,
        MessageData: &packets.Message_LeftRoom{LeftRoom: msg},
    })
}
func (s *PlayerSession) sendReceivedMessage(msg *packets.ReceivedMessage) {
    s.marshalAndSendMessage(&packets.Message{
        MessageType: packets.MessageType_RECEIVED_MESSAGE,
        MessageData: &packets.Message_ReceivedMessage{ReceivedMessage: msg},
    })
}
func (s *PlayerSession) sendReceivedAction(msg *packets.ReceivedAction) {
    s.marshalAndSendMessage(&packets.Message{
        MessageType: packets.MessageType_RECEIVED_ACTION,
        MessageData: &packets.Message_ReceivedAction{ReceivedAction: msg},
    })
}

func (s *PlayerSession) readLoop() {
    msg := &packets.Message{}
    for {
        _, data, err := s.conn.ReadMessage()
        if err != nil {
            log.Println("Failed to read message:", err)
            break
        }
        if err := proto.Unmarshal(data, msg); err != nil {
            panic(err)
        }
        go s.handleMessage(msg)
    }
}

func (s *PlayerSession) isLoggedIn() bool {
    return s.loggedIn
}
func (s *PlayerSession) isInRoom() bool {
    return s.currentRoom != packets.RoomID_NONE
}

func (s *PlayerSession) handleMessage(msg *packets.Message) {
    switch msg.GetMessageType() {
    case packets.MessageType_LOGIN:
        if login := msg.GetLogin(); login != nil {
            log.Println("Got login message. Username:", login.GetName())
            s.username = login.GetName()
            s.loggedIn = true
            // TODO(mvh): Send response to client here acknowledging that they have logged in.
        }
    case packets.MessageType_JOIN_ROOM:
        if s.loggedIn == false { // Don't do stuff unless logged in.
            return
        }
        if joinRoom := msg.GetJoinRoom(); joinRoom != nil {
            log.Println("User wants to join room:", joinRoom.GetRoomID())
            // TODO(mvh): Validate that the room is is correct. (Unless that is something protobuf already does.)
            if s.isLoggedIn() == false { // Don't do stuff unless logged in.
                return
            }
            if s.currentRoom == joinRoom.GetRoomID() { // Don't change room if it's the same room.
                return
            }
            if s.isInRoom() { // Only leave the room if the user is the user is already in one.
                s.ctx.Send(s.serverPID, &packets.LeftRoom{
                    UserID: s.userID,
                    RoomID: s.currentRoom,
                })
            }
            s.currentRoom = joinRoom.GetRoomID()
            s.ctx.Send(s.serverPID, &packets.JoinedRoom{
                UserName: s.username,
                UserID:   s.userID,
                RoomID:   s.currentRoom,
                Position: joinRoom.GetPosition(),
            })
        }
    case packets.MessageType_SEND_MESSAGE:
        if s.isLoggedIn() == false { // Don't do stuff unless logged in.
            return
        }
        if s.isInRoom() == false { // Don't change room if it's not the same room.
            return
        }
        if sendMessage := msg.GetSendMessage(); sendMessage != nil {
            log.Println("User wants to send message:", sendMessage.GetContent())
            s.ctx.Send(s.serverPID, &packets.ReceivedMessage{
                UserID:  s.userID,
                Content: sendMessage.GetContent(),
                RoomID: s.currentRoom,
            })
        }
    case packets.MessageType_BEGIN_ACTION:
        if s.isLoggedIn() == false { // Don't do stuff unless logged in.
            return
        }
        if s.isInRoom() == false { // Don't change room if it's the same room.
            return
        }
        if beginAction := msg.GetBeginAction(); beginAction != nil {
            s.ctx.Send(s.serverPID, &packets.ReceivedAction{
                UserID: s.userID,
                Action: beginAction,
                RoomID: s.currentRoom,
            })
        }
    default:
        log.Println("Got message from client that should be from server:", msg.GetMessageType().String())
    }
}
