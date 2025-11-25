# StreamSync Lite - System Architecture

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           CLIENT LAYER                                  │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌────────────────────┐         ┌────────────────────┐                 │
│  │   Flutter Mobile   │         │   Flutter Web      │                 │
│  │   (iOS/Android)    │         │   (Browser)        │                 │
│  └─────────┬──────────┘         └─────────┬──────────┘                 │
│            │                              │                              │
│            └──────────────┬───────────────┘                              │
│                           │                                              │
│                    HTTP/REST API                                         │
│                           │                                              │
└───────────────────────────┼──────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        APPLICATION LAYER                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    Express.js Backend                           │   │
│  │                   (Node.js + TypeScript)                        │   │
│  ├─────────────────────────────────────────────────────────────────┤   │
│  │                                                                   │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │   │
│  │  │   Auth       │  │   Video      │  │   Progress   │          │   │
│  │  │   Controller │  │   Controller │  │   Controller │          │   │
│  │  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │   │
│  │         │                  │                  │                  │   │
│  │         └──────────────────┼──────────────────┘                  │   │
│  │                            │                                     │   │
│  │  ┌─────────────────────────┴─────────────────────────┐          │   │
│  │  │              Business Logic Layer                 │          │   │
│  │  │  • JWT Authentication                             │          │   │
│  │  │  • Video Management                               │          │   │
│  │  │  • Progress Tracking                              │          │   │
│  │  │  • Favorites Management                           │          │   │
│  │  └─────────────────────────┬─────────────────────────┘          │   │
│  │                            │                                     │   │
│  │  ┌─────────────────────────┴─────────────────────────┐          │   │
│  │  │              Sequelize ORM                        │          │   │
│  │  └─────────────────────────┬─────────────────────────┘          │   │
│  │                            │                                     │   │
│  └────────────────────────────┼─────────────────────────────────────┘   │
│                               │                                          │
└───────────────────────────────┼──────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         DATA LAYER                                      │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌────────────────────────────────────────────────────────────┐         │
│  │                    MySQL Database                          │         │
│  ├────────────────────────────────────────────────────────────┤         │
│  │                                                            │         │
│  │  ┌─────────┐  ┌─────────┐  ┌──────────────┐  ┌────────┐  │         │
│  │  │  Users  │  │ Videos  │  │ VideoProgress│  │Tokens  │  │         │
│  │  ├─────────┤  ├─────────┤  ├──────────────┤  ├────────┤  │         │
│  │  │ id      │  │ id      │  │ id           │  │id      │  │         │
│  │  │ email   │  │ title   │  │ userId       │  │userId  │  │         │
│  │  │ password│  │ desc    │  │ videoId      │  │token   │  │         │
│  │  │ name    │  │ url     │  │ position     │  │type    │  │         │
│  │  │ avatar  │  │thumbnail│  │ duration     │  │expires │  │         │
│  │  └────┬────┘  └────┬────┘  └──────┬───────┘  └───┬────┘  │         │
│  │       │            │              │              │        │         │
│  │       └────────┬───┴──────────────┴──────────────┘        │         │
│  │                │  Foreign Key Relationships               │         │
│  │                │  • Users ← VideoProgress                 │         │
│  │                │  • Videos ← VideoProgress                │         │
│  │                │  • Users ← Tokens                        │         │
│  │                │  • Users ← Videos (favorites)            │         │
│  └────────────────────────────────────────────────────────────┘         │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                    EXTERNAL SERVICES                                    │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌──────────────────────┐         ┌──────────────────────┐              │
│  │  Firebase Cloud      │         │  Cloud Storage       │              │
│  │  Messaging (FCM)     │         │  (Video Files)       │              │
│  │  • Push Notifications│         │  • S3/CloudFlare     │              │
│  └──────────────────────┘         └──────────────────────┘              │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘
```

## Flutter App Architecture (BLoC Pattern)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       PRESENTATION LAYER                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐        │
│  │  Home      │  │ Favorites  │  │   Video    │  │  Profile   │        │
│  │  Screen    │  │  Screen    │  │  Player    │  │  Screen    │        │
│  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘        │
│        │               │               │               │                │
│        └───────────────┴───────────────┴───────────────┘                │
│                             │                                            │
│                        Widget Tree                                       │
│                             │                                            │
└─────────────────────────────┼────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        BUSINESS LOGIC LAYER                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌──────────────────────────────────────────────────────────────┐       │
│  │                       BLoC Components                        │       │
│  ├──────────────────────────────────────────────────────────────┤       │
│  │                                                              │       │
│  │  ┌─────────────┐  ┌─────────────┐  ┌──────────────┐        │       │
│  │  │  VideoBloc  │  │  AuthBloc   │  │ ProgressBloc │        │       │
│  │  ├─────────────┤  ├─────────────┤  ├──────────────┤        │       │
│  │  │ Events:     │  │ Events:     │  │ Events:      │        │       │
│  │  │ • LoadVideo │  │ • Login     │  │ • Update     │        │       │
│  │  │ • Toggle    │  │ • Register  │  │ • Save       │        │       │
│  │  │   Favorite  │  │ • Logout    │  │              │        │       │
│  │  │             │  │             │  │              │        │       │
│  │  │ States:     │  │ States:     │  │ States:      │        │       │
│  │  │ • Loading   │  │ • Initial   │  │ • Tracking   │        │       │
│  │  │ • Loaded    │  │ • Auth      │  │ • Updated    │        │       │
│  │  │ • Error     │  │ • Unauth    │  │              │        │       │
│  │  └──────┬──────┘  └──────┬──────┘  └───────┬──────┘        │       │
│  │         │                │                 │                │       │
│  │         └────────────────┼─────────────────┘                │       │
│  │                          │                                  │       │
│  └──────────────────────────┼──────────────────────────────────┘       │
│                             │                                           │
└─────────────────────────────┼───────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                          DATA LAYER                                     │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌──────────────────────────────────────────────────────────────┐       │
│  │                      Repositories                            │       │
│  ├──────────────────────────────────────────────────────────────┤       │
│  │  • VideoRepository                                           │       │
│  │  • AuthRepository                                            │       │
│  │  • ProgressRepository                                        │       │
│  └────────────────────────┬─────────────────────────────────────┘       │
│                           │                                              │
│  ┌────────────────────────┴─────────────────────────────────┐           │
│  │                    Data Sources                          │           │
│  ├──────────────────────────────────────────────────────────┤           │
│  │                                                          │           │
│  │  ┌─────────────────┐           ┌──────────────────┐    │           │
│  │  │  API Service    │           │  Local Storage   │    │           │
│  │  │  (HTTP Client)  │           │  (Hive DB)       │    │           │
│  │  ├─────────────────┤           ├──────────────────┤    │           │
│  │  │ • GET /videos   │           │ • Cached Videos  │    │           │
│  │  │ • POST /login   │           │ • User Token     │    │           │
│  │  │ • PUT /favorite │           │ • Preferences    │    │           │
│  │  │ • PUT /progress │           │ • Watch History  │    │           │
│  │  └─────────────────┘           └──────────────────┘    │           │
│  │                                                          │           │
│  └──────────────────────────────────────────────────────────┘           │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘
```

## Data Flow Diagrams

### 1. User Authentication Flow
```
┌──────────┐         ┌──────────┐         ┌──────────┐         ┌──────────┐
│  Login   │   1.    │  AuthBloc│   2.    │   API    │   3.    │  MySQL   │
│  Screen  ├────────▶│          ├────────▶│  Service ├────────▶│  Users   │
└──────────┘ Email/  └──────────┘  POST   └──────────┘  Query  └──────────┘
             Password    Event     /login                         ▲
                                                                  │
             ┌────────────────────────────────────────────────────┘
             │ 4. Hash Check
             │
┌──────────┐ │ 5.    ┌──────────┐  6.     ┌──────────┐   7.     ┌──────────┐
│  Hive    │◀────────│ AuthBloc │◀────────│   API    │◀─────────│   JWT    │
│  Storage │  Store  │          │  Token  │  Service │  Generate│  Service │
└──────────┘  Token  └──────────┘ Response└──────────┘           └──────────┘
```

### 2. Video Loading & Favorites Flow
```
┌──────────┐   1.    ┌───────────┐   2.    ┌──────────┐   3.    ┌──────────┐
│   Home   │  Load   │ VideoBloc │   GET   │   API    │  Query  │  MySQL   │
│  Screen  ├────────▶│           ├────────▶│  Service ├────────▶│  Videos  │
└──────────┘  Event  └───────────┘ /videos └──────────┘          └────┬─────┘
                                                                       │
                                                                       │ JOIN
                                                                       ▼
                          ┌─────────────────────────────────┐  ┌──────────────┐
                          │    Response with Videos         │  │Video         │
                          │    [id, title, isFavorite, ...] │◀─│Progress      │
                          └──────────┬──────────────────────┘  └──────────────┘
                                     │
                          4.         ▼
┌──────────┐          ┌───────────────────┐
│  Widget  │◀─────────│  Loaded State     │
│  Rebuild │  Display │  with Videos      │
└──────────┘          └───────────────────┘
```

### 3. Video Progress Tracking Flow
```
┌──────────────┐    1.     ┌──────────────┐    2.     ┌──────────┐
│ VideoPlayer  │  Position │ ProgressBloc │  Debounce │  Local   │
│   Widget     ├──────────▶│              ├──────────▶│  Buffer  │
└──────────────┘   Update  └──────────────┘   500ms   └────┬─────┘
                     Event                                  │
                                                            │ 3.
                                                            ▼
┌──────────────┐    5.     ┌──────────────┐    4.     ┌──────────┐
│    MySQL     │◀──────────│     API      │◀──────────│  Batch   │
│VideoProgress │  Update   │   Service    │   PUT     │  Sender  │
└──────────────┘  Position └──────────────┘  /progress└──────────┘
```

## Deployment Architecture (Docker)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          Docker Host                                    │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌────────────────────────────────────────────────────────────┐         │
│  │              Docker Compose Network                        │         │
│  │              (stream_sync_network)                         │         │
│  │                                                            │         │
│  │  ┌──────────────────┐  ┌──────────────────┐  ┌─────────┐ │         │
│  │  │   Frontend       │  │   Backend        │  │  MySQL  │ │         │
│  │  │   Container      │  │   Container      │  │Container│ │         │
│  │  ├──────────────────┤  ├──────────────────┤  ├─────────┤ │         │
│  │  │ Nginx:alpine     │  │ Node:22-alpine   │  │mysql:8.0│ │         │
│  │  │ Port: 80         │  │ Port: 3000       │  │Port:3306│ │         │
│  │  │                  │  │                  │  │         │ │         │
│  │  │ /usr/share/nginx │  │ /app/dist        │  │ Volume: │ │         │
│  │  │ /html            │  │                  │  │mysql_data│ │         │
│  │  └────────┬─────────┘  └────────┬─────────┘  └────┬────┘ │         │
│  │           │                     │                 │      │         │
│  │           └─────────────────────┼─────────────────┘      │         │
│  │                                 │                        │         │
│  └─────────────────────────────────┼────────────────────────┘         │
│                                    │                                    │
│  ┌─────────────────────────────────┼────────────────────────┐          │
│  │         Port Mapping            │                        │          │
│  │  Host:8080 → Container:80   ────┘                        │          │
│  │  Host:3000 → Container:3000                              │          │
│  │  Host:3306 → Container:3306                              │          │
│  └──────────────────────────────────────────────────────────┘          │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘
```

## Security Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         Security Layers                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  1. Transport Layer                                                      │
│     ┌───────────────────────────────────────────────┐                   │
│     │ HTTPS/TLS 1.3                                 │                   │
│     │ • Certificate validation                      │                   │
│     │ • Encrypted communication                     │                   │
│     └───────────────────────────────────────────────┘                   │
│                                                                           │
│  2. Authentication Layer                                                 │
│     ┌───────────────────────────────────────────────┐                   │
│     │ JWT (JSON Web Tokens)                         │                   │
│     │ • Access Token (1 day expiry)                 │                   │
│     │ • Refresh Token (7 days expiry)               │                   │
│     │ • Token stored in secure storage (Hive)       │                   │
│     └───────────────────────────────────────────────┘                   │
│                                                                           │
│  3. Authorization Layer                                                  │
│     ┌───────────────────────────────────────────────┐                   │
│     │ Middleware Authentication                      │                   │
│     │ • Verify JWT signature                        │                   │
│     │ • Check token expiry                          │                   │
│     │ • User context injection                      │                   │
│     └───────────────────────────────────────────────┘                   │
│                                                                           │
│  4. Data Protection Layer                                                │
│     ┌───────────────────────────────────────────────┐                   │
│     │ Password Hashing                              │                   │
│     │ • bcrypt with salt (10 rounds)                │                   │
│     │ • Never store plaintext passwords             │                   │
│     └───────────────────────────────────────────────┘                   │
│                                                                           │
│  5. API Security Layer                                                   │
│     ┌───────────────────────────────────────────────┐                   │
│     │ • CORS configuration                          │                   │
│     │ • Rate limiting                               │                   │
│     │ • Input validation                            │                   │
│     │ • SQL injection prevention (Sequelize ORM)    │                   │
│     │ • XSS protection (helmet.js)                  │                   │
│     └───────────────────────────────────────────────┘                   │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘
```

## Scalability Considerations

### Horizontal Scaling
```
                    ┌─────────────────┐
                    │  Load Balancer  │
                    │   (Nginx/HAProxy│
                    └────────┬────────┘
                             │
          ┌──────────────────┼──────────────────┐
          │                  │                  │
    ┌─────▼────┐      ┌──────▼─────┐    ┌──────▼─────┐
    │ Backend  │      │  Backend   │    │  Backend   │
    │ Instance │      │  Instance  │    │  Instance  │
    │    #1    │      │     #2     │    │     #3     │
    └─────┬────┘      └──────┬─────┘    └──────┬─────┘
          │                  │                  │
          └──────────────────┼──────────────────┘
                             │
                    ┌────────▼────────┐
                    │   MySQL Cluster │
                    │  (Master-Slave) │
                    └─────────────────┘
```

### Caching Strategy
```
┌──────────┐     ┌───────────┐     ┌──────────┐     ┌──────────┐
│  Client  ├────▶│   Redis   ├────▶│ Backend  ├────▶│  MySQL   │
└──────────┘     └───────────┘     └──────────┘     └──────────┘
                 Cache Hit           Cache Miss       Database
                 (Fast Response)     (DB Query)       (Authoritative)
```

## Technology Stack

### Frontend
- **Framework**: Flutter 3.19.2
- **Language**: Dart 3.3.0
- **State Management**: flutter_bloc ^8.1.3
- **Storage**: hive ^2.2.3, hive_flutter ^1.1.0
- **Video Player**: video_player ^2.8.1
- **HTTP Client**: dio ^5.4.0
- **UI**: Cupertino/Material Design

### Backend
- **Runtime**: Node.js 22.x
- **Framework**: Express.js 4.x
- **Language**: TypeScript 5.x
- **ORM**: Sequelize 6.x
- **Authentication**: JWT (jsonwebtoken)
- **Security**: bcrypt, helmet, cors
- **Validation**: express-validator

### Database
- **RDBMS**: MySQL 8.0
- **Schema**: Users, Videos, VideoProgress, Tokens
- **Indexing**: Primary keys, Foreign keys, userId indexes

### DevOps
- **Containerization**: Docker, Docker Compose
- **Web Server**: Nginx (for Flutter web)
- **Testing**: Jest (Backend), flutter_test (Frontend)
- **Version Control**: Git

### External Services
- **Push Notifications**: Firebase Cloud Messaging (FCM)
- **Video Storage**: Cloud storage (S3/CloudFlare)

## API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/refresh` - Refresh access token
- `POST /api/auth/logout` - User logout

### Videos
- `GET /api/videos` - Get all videos
- `GET /api/videos/:id` - Get single video
- `PUT /api/videos/:id/favorite` - Toggle favorite status
- `GET /api/videos/favorites` - Get user's favorites

### Progress
- `GET /api/progress/:videoId` - Get video progress
- `PUT /api/progress/:videoId` - Update video progress
- `GET /api/progress` - Get all user progress

### User
- `GET /api/user/profile` - Get user profile
- `PUT /api/user/profile` - Update user profile
- `PUT /api/user/password` - Change password

## Key Design Patterns

1. **BLoC Pattern** (Frontend)
   - Separation of business logic from UI
   - Reactive state management
   - Testable architecture

2. **Repository Pattern** (Frontend)
   - Abstract data sources
   - Single source of truth
   - Easy to mock for testing

3. **MVC Pattern** (Backend)
   - Models: Sequelize ORM models
   - Views: JSON responses
   - Controllers: Route handlers

4. **Middleware Pattern** (Backend)
   - Authentication middleware
   - Error handling middleware
   - Logging middleware

5. **Dependency Injection**
   - Testable components
   - Loose coupling
   - Easy to extend

---

*For detailed implementation guides, see README.md and DOCKER.md*
