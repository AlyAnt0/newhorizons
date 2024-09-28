package main

import (
	"gameserver/server"
	"log"

	"github.com/anthdm/hollywood/actor"
)

func main() {
    engine, err := actor.NewEngine(actor.NewEngineConfig())
    if err != nil {
        log.Println("Engine start failed.")
        panic(err)
    }
    engine.Spawn(server.NewGameServer, "server")
    select {}
}
