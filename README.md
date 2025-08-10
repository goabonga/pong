# 🕹️ Pong in SQL

A fully functional ASCII Pong game implemented **entirely in MySQL**, using:

- A `pong_state` table to track ball and paddle positions
- Stored procedures to simulate ball physics and paddle AI
- A MySQL `EVENT` to update the game state every second
- A visual `render_full_frame_lines()` procedure that returns a styled ASCII frame
- A Docker setup with MySQL + phpMyAdmin for testing

## 🚀 Quickstart

### 1. Launch the containers

```bash
docker-compose up -d
```

### 2. Start the animation

```bash
./render.sh
```

This uses docker exec and MySQL's ASCII rendering procedure to show the game in real time.

### 3. View the game state manually (optional)

Go to: http://localhost:8080

Login with:
 - User: root
 - Password: root

Then run:

```sql
CALL render_full_frame_lines();
```

🛠️ Developer Notes

- Ball and paddle logic is managed by `move_ball()`
- AI paddles follow the ball automatically
- The event game_tick runs every second via MySQL's **EVENT SCHEDULER**

## 💡 Tip

To reset the game manually:

```sql
CALL reset_game();
```

## 🤖 AI Assistance Disclosure

📝 This project was created with the assistance of an AI agent, guided and validated by a human developer to ensure the quality, accuracy, and relevance of the code and documentation.

---

Built for fun and education. Yes, SQL can play Pong 🏓