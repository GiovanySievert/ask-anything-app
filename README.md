# ask-anything-app

The iOS client for [ask-anything](https://github.com/GiovanySievert/ask-anything):
a SwiftUI chat app for talking to an AI that answers from your own technical
material, streaming its reply back token by token.

Ingest your documents once. From then on, every answer is grounded in them —
the model is reasoning over your material, not over whatever it happens to
remember.

## What it does

**Chat, grounded.** You ask in plain language and the reply is built from the
chunks of your documents that actually relate to the question. Retrieval runs on
every turn, so a conversation that drifts into a new topic pulls in new sources
as it goes.

**Streamed, not awaited.** Replies arrive token by token over Server-Sent
Events. The bubble fills in as the model writes, instead of showing a spinner
until a full response lands.

**Multi-turn, persisted.** Conversations are kept server-side with their full
history, so follow-ups land in context ("and what about the JS thread?") and
your chats survive a relaunch. The chat list is your history.

## Stack

| Concern  | Choice                                                              |
| -------- | ------------------------------------------------------------------- |
| UI       | SwiftUI                                                             |
| State    | `@Observable` view models                                           |
| Type     | Inter Tight (text), JetBrains Mono (display)                        |
| Surfaces | Liquid Glass (`glassEffect`)                                        |
| Backend  | [ask-anything](https://github.com/GiovanySievert/ask-anything) (Go) |

## Getting started

Requires Xcode 16+ and the backend running on `http://localhost:8080` — see its
README for setup (Postgres/pgvector, Ollama, and an Anthropic API key).

```bash
open ask-anything-app.xcodeproj
```

## How it talks to the backend

Base path: `/api/v1`.

| What the app does     | Call                                      |
| --------------------- | ----------------------------------------- |
| Show the chat list    | `GET /conversations`                      |
| Start a chat          | `POST /conversations`                     |
| Open a chat           | `GET /conversations/{id}/messages`        |
| Send a message        | `POST /conversations/{id}/messages` (SSE) |

Sending a message opens a stream rather than returning a single JSON body. The
app appends each `delta` to the assistant's bubble as it arrives, then settles on
the persisted message carried by the terminal `done` event:

```
event: delta
data: {"text":"To optimize a slow "}

event: delta
data: {"text":"FlatList, use getItemLayout..."}

event: done
data: {"id":"...","role":"assistant","content":"...","created_at":"..."}
```

The retrieval is invisible from here: the app sends text and receives text. The
backend embeds the outgoing message locally, searches pgvector for the nearest
chunks, and hands those to Claude alongside the conversation so far.

## Project layout

```
ask-anything-app/
  App/                    # entrypoint, ContentView
  Features/
    Chat/                 # the conversation: view, bubbles, input bar, empty state
    ChatList/             # past conversations
  Shared/
    DesignSystem/         # AppColors, AppTypography, AppSpacing
    Components/
  Extensions/             # view helpers, e.g. the appGlass modifier
  Resources/Fonts/
  Services/               # API client
```

Features own their views and view models; whatever two of them share moves up to
`Shared/`. Colors, type, and spacing come from design system tokens rather than
being written inline, so a change lands in one place.
