#!/bin/bash

# 05_start_containers.sh
# Start and manage Docker containers

set -e

echo "🚀 Container Management"
echo "======================="

# Check if containers are built
check_containers_built() {
    if ! docker images | grep -q "dovsg"; then
        echo "❌ Containers not built yet!"
        echo "Please run: ./scripts/04_build_containers.sh first"
        exit 1
    fi
    echo "✅ Container images found"
}

# Show container status
show_container_status() {
    echo ""
    echo "📊 Container Status:"
    echo "==================="
    
    if docker compose ps | grep -q "Up"; then
        echo "✅ Containers are running:"
        docker compose ps
    else
        echo "⏸️  Containers are not running"
        docker compose ps
    fi
}

# Start containers
start_containers() {
    echo ""
    echo "🚀 Starting containers..."
    
    docker compose up -d
    
    echo ""
    echo "✅ Containers started!"
    
    # Wait a moment for containers to fully start
    sleep 3
    
    echo ""
    echo "📊 Current status:"
    docker compose ps
}

# Stop containers
stop_containers() {
    echo ""
    echo "🛑 Stopping containers..."
    
    docker compose down
    
    echo "✅ Containers stopped!"
}

# Restart containers
restart_containers() {
    echo ""
    echo "🔄 Restarting containers..."
    
    docker compose restart
    
    echo "✅ Containers restarted!"
    
    sleep 3
    docker compose ps
}

# View logs
view_logs() {
    echo ""
    echo "📋 Container logs:"
    echo "=================="
    echo "Press Ctrl+C to exit log view"
    echo ""
    
    docker compose logs -f
}

# Test containers
test_containers() {
    echo ""
    echo "🧪 Testing containers..."
    
    echo ""
    echo "Testing DovSG container:"
    if docker compose exec -T dovsg conda run -n dovsg python --version; then
        echo "✅ DovSG container working"
    else
        echo "❌ DovSG container not responding"
    fi
    
    echo ""
    echo "Testing DROID-SLAM container:"
    if docker compose exec -T droid-slam conda run -n droidenv python --version; then
        echo "✅ DROID-SLAM container working"
    else
        echo "❌ DROID-SLAM container not responding"
    fi
    
    echo ""
    echo "Testing GPU access:"
    if docker compose exec -T dovsg nvidia-smi | head -1; then
        echo "✅ GPU access working"
    else
        echo "❌ GPU access not working"
    fi
}

# Interactive shells
open_dovsg_shell() {
    echo ""
    echo "🐚 Opening DovSG shell..."
    echo "Type 'exit' to return"
    echo ""
    
    docker compose exec dovsg conda run -n dovsg bash
}

open_droid_shell() {
    echo ""
    echo "🐚 Opening DROID-SLAM shell..."
    echo "Type 'exit' to return"
    echo ""
    
    docker compose exec droid-slam conda run -n droidenv bash
}

# Show menu
show_menu() {
    echo ""
    echo "Available actions:"
    echo "1. Start containers"
    echo "2. Stop containers" 
    echo "3. Restart containers"
    echo "4. View logs"
    echo "5. Test containers"
    echo "6. Open DovSG shell"
    echo "7. Open DROID-SLAM shell"
    echo "8. Show container status"
    echo "9. Exit"
    echo ""
}

# Main menu loop
main() {
    check_containers_built
    show_container_status
    
    while true; do
        show_menu
        read -p "Choose an action (1-9): " choice
        
        case $choice in
            1)
                start_containers
                ;;
            2)
                stop_containers
                ;;
            3)
                restart_containers
                ;;
            4)
                view_logs
                ;;
            5)
                test_containers
                ;;
            6)
                open_dovsg_shell
                ;;
            7)
                open_droid_shell
                ;;
            8)
                show_container_status
                ;;
            9)
                echo "👋 Exiting"
                break
                ;;
            *)
                echo "❌ Invalid option. Please choose 1-9."
                ;;
        esac
    done
}

main "$@"