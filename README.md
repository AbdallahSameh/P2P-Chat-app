P2P Chat App (Flutter)

A peer-to-peer chat application built with Flutter, enabling real-time communication over a local network without any central server.
The app supports host/client roles, local discovery, and direct TCP communication, making it fully decentralized.

🚀 Features
    Peer-to-peer architecture (no backend server)

    🌐 Local network discovery using UDP

    💬 Real-time chat over TCP sockets

    🧑‍💻 Host & Client modes

    🔐 Optional room password

    📱 Custom reusable UI components

    🧠 Provider-based state management

    🧩 Clean separation between UI, logic, and networking layers

🛠 Tech Stack

    Flutter (Dart)

    TCP & UDP Sockets

    Provider for state management

    Custom Widgets & Dialogs

Material Design

    🧠 Architecture Overview
        lib/
        ├── chat service/        # Networking logic (TCP / UDP)
        ├── data models/         # Message, Room, User models
        ├── provider/            # App state management
        ├── ui/
        │   ├── screens          # Main application screens
        │   ├── dialogues        # Custom dialogs
        │   └── shared           # Reusable UI components
        └── interfaces/          # Abstractions for chat types


        Networking layer handles socket communication

        Provider layer manages app state

        UI layer reacts to state changes only

        Interfaces allow extensibility between host/client roles

📡 How It Works

    A user selects Host or Client

    Hosts create a room and broadcast availability via UDP

    Clients discover rooms on the local network

    TCP sockets are used for real-time messaging

    Messages are distributed directly between peers

📸 Screenshots
![Screenshot 1](screenshots/Screenshot_1770122312.png)
![Screenshot 2](screenshots/Screenshot_1770122328.png)
![Screenshot 3](screenshots/Screenshot_1770122333.png)
![Screenshot 4](screenshots/Screenshot%202026-02-03%20144238.png)
![Screenshot 5](screenshots/Screenshot%202026-02-03%20144301.png)
![Screenshot 6](screenshots/Screenshot%202026-02-03%20144337.png)

