.PHONY: iex_server ngrok_host server stop_ngrok

ngrok_host:
	@if ! pgrep -f ngrok > /dev/null; then \
		ngrok http 4000 > /dev/null 2>&1 & \
		sleep 2; \
	fi
	@curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"[^"]*"' | head -1 | cut -d'"' -f4 | sed 's|^https://||'

server:
	@echo "Starting server with ngrok..."
	@export PHX_HOST=$$(make ngrok_host); \
	export PHX_SERVER=true; \
	mix phx.server

iex_server:
	@echo "Starting IEx with server and ngrok..."
	@export PHX_HOST=$$(make ngrok_host); \
	export PHX_SERVER=true; \
	iex -S mix phx.server

stop_ngrok:
	@pkill -f ngrok
