package server

import (
    "fmt"
    "gameserver/player"
    "gameserver/packets"
    "log"
    "net/http"

    "github.com/anthdm/hollywood/actor"
    "github.com/gorilla/websocket"
)

type GameServer struct {
    ctx      *actor.Context
    sessions map[uint64]*actor.PID
}

func NewGameServer() actor.Receiver {
    return &GameServer{
        sessions: make(map[uint64]*actor.PID),
    }
}

func (s *GameServer) Receive(ctx *actor.Context) {
    switch msg := ctx.Message().(type) {
    case actor.Started:
        s.ctx = ctx
        s.startHTTP()
        _ = msg
    case *packets.JoinedRoom:
        s.broadcastJoinedRoom(ctx.Sender(), msg)
    case *packets.LeftRoom:
        s.broadcastLeftRoom(ctx.Sender(), msg)
    case *packets.ReceivedMessage:
        s.broadcastReceivedMessage(ctx.Sender(), msg)
    case *packets.ReceivedAction:
        s.broadcastReceivedAction(ctx.Sender(), msg)
    default:
        log.Println("Unhandled game server message", msg)
    }
}

// TODO(mvh): Find a way to lower the repetition here.
func (s *GameServer) broadcastJoinedRoom(from *actor.PID, message *packets.JoinedRoom) {
    for _, pid := range s.sessions {
        if pid.Equals(from) == false {
            s.ctx.Send(pid, message)
        }
    }
}
func (s *GameServer) broadcastLeftRoom(from *actor.PID, message *packets.LeftRoom) {
    for _, pid := range s.sessions {
        if pid.Equals(from) == false {
            s.ctx.Send(pid, message)
        }
    }
}
func (s *GameServer) broadcastReceivedMessage(from *actor.PID, message *packets.ReceivedMessage) {
    for _, pid := range s.sessions {
        if pid.Equals(from) == false {
            s.ctx.Send(pid, message)
        }
    }
}
func (s *GameServer) broadcastReceivedAction(from *actor.PID, message *packets.ReceivedAction) {
    for _, pid := range s.sessions {
        if pid.Equals(from) == false {
            s.ctx.Send(pid, message)
        }
    }
}

// TODO(mvh): Figure out how to pass the port as an argument to the server.
const port = "9999"

func (s *GameServer) startHTTP() {
    log.Println("Starting HTTP server on port", port)
    go func() {
        http.HandleFunc("/ws", s.handleWS)
        http.ListenAndServe(":"+port, nil)
    }()
}

// NOTE(mvh): It's stupid but it works.  With 10 million connections per millisecond (completely insane),
//              it would take about 58 years until it would wrap around... which is more than enough.
var userCounter uint64 = 0

// Handle the upgrade of the websocket
func (s *GameServer) handleWS(w http.ResponseWriter, r *http.Request) {
    const readBufSize = 1024
    const writeBufSize = 1024
    conn, err := websocket.Upgrade(w, r, nil, readBufSize, writeBufSize)
    if err != nil {
        log.Println("Websocket upgrade error:", err)
        return
    }
    log.Println("New client trying to connect")
    userID := userCounter
    userCounter++
    pid := s.ctx.SpawnChild(player.NewPlayerSession(s.ctx.PID(), userID, conn), fmt.Sprintf("player_session_%d", userID))
    s.sessions[userID] = pid

}
