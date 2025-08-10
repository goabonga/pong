#!/bin/bash

watch -n1 \
'docker exec mysql-pong mysql -uroot -proot -D pong -sN -e "CALL render_full_frame_lines()"'