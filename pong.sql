DROP DATABASE IF EXISTS pong;
CREATE DATABASE pong;
USE pong;

DROP TABLE IF EXISTS pong_state;

CREATE TABLE pong_state (
    id INT PRIMARY KEY,
    ball_x INT,
    ball_y INT,
    ball_dx INT,
    ball_dy INT,
    paddle1_y INT,
    paddle2_y INT,
    paddle_height INT,
    width INT,
    height INT
);

INSERT INTO pong_state VALUES (1, 5, 5, 1, 1, 4, 4, 3, 20, 10);

DELIMITER //

DROP PROCEDURE IF EXISTS move_ball;

CREATE PROCEDURE move_ball()
BEGIN
    DECLARE new_x INT;
    DECLARE new_y INT;
    DECLARE s_width INT;
    DECLARE s_height INT;
    DECLARE s_dx INT;
    DECLARE s_dy INT;
    DECLARE s_x INT;
    DECLARE s_y INT;
    DECLARE p1_y INT;
    DECLARE p2_y INT;
    DECLARE p_h INT;

    SELECT width, height, ball_dx, ball_dy, ball_x, ball_y, paddle1_y, paddle2_y, paddle_height
    INTO s_width, s_height, s_dx, s_dy, s_x, s_y, p1_y, p2_y, p_h
    FROM pong_state WHERE id = 1;

    SET new_x = s_x + s_dx;
    SET new_y = s_y + s_dy;

    IF new_y <= 0 OR new_y >= s_height THEN
        SET s_dy = -s_dy;
        SET new_y = s_y + s_dy;
    END IF;

    IF new_x = 1 THEN
        IF new_y BETWEEN p1_y AND (p1_y + p_h - 1) THEN
            SET s_dx = -s_dx;
            SET new_x = s_x + s_dx;
        END IF;
    ELSEIF new_x = s_width THEN
        IF new_y BETWEEN p2_y AND (p2_y + p_h - 1) THEN
            SET s_dx = -s_dx;
            SET new_x = s_x + s_dx;
        END IF;
    END IF;

    UPDATE pong_state
    SET ball_x = new_x,
        ball_y = new_y,
        ball_dx = s_dx,
        ball_dy = s_dy
    WHERE id = 1;
END //

DROP PROCEDURE IF EXISTS reset_game;

CREATE PROCEDURE reset_game()
BEGIN
    UPDATE pong_state
    SET ball_x = 5,
        ball_y = 5,
        ball_dx = 1,
        ball_dy = 1,
        paddle1_y = 4,
        paddle2_y = 4;
END //


DROP PROCEDURE IF EXISTS render_full_frame_lines;

CREATE PROCEDURE render_full_frame_lines()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE j INT;
    DECLARE row_line TEXT;
    DECLARE s_x INT;
    DECLARE s_y INT;
    DECLARE p1_y INT;
    DECLARE p2_y INT;
    DECLARE p_h INT;
    DECLARE w INT;
    DECLARE h INT;

    SELECT ball_x, ball_y, paddle1_y, paddle2_y, paddle_height, width, height
    INTO s_x, s_y, p1_y, p2_y, p_h, w, h
    FROM pong_state
    WHERE id = 1;

    -- Top border
    SELECT CONCAT('+', REPEAT('-', w), '+') AS frame_line;

    WHILE i < h DO
        SET row_line = '|';
        SET j = 1;
        WHILE j <= w DO
            IF j = 1 AND i BETWEEN p1_y AND p1_y + p_h - 1 THEN
                SET row_line = CONCAT(row_line, '|');
            ELSEIF j = w AND i BETWEEN p2_y AND p2_y + p_h - 1 THEN
                SET row_line = CONCAT(row_line, '|');
            ELSEIF j = s_x AND i = s_y THEN
                SET row_line = CONCAT(row_line, 'o');
            ELSE
                SET row_line = CONCAT(row_line, '*');
            END IF;
            SET j = j + 1;
        END WHILE;
        SET row_line = CONCAT(row_line, '|');
        SELECT row_line AS frame_line;
        SET i = i + 1;
    END WHILE;

    -- Bottom border
    SELECT CONCAT('+', REPEAT('-', w), '+') AS frame_line;
END //


DROP EVENT IF EXISTS game_tick;

CREATE EVENT game_tick
ON SCHEDULE EVERY 1 SECOND
ON COMPLETION PRESERVE
ENABLE
DO
BEGIN
    CALL move_ball();
    UPDATE pong_state
    SET paddle1_y = LEAST(GREATEST(ball_y - 1, 0), height - paddle_height),
        paddle2_y = LEAST(GREATEST(ball_y - 1, 0), height - paddle_height)
    WHERE id = 1;
END //

DELIMITER ;