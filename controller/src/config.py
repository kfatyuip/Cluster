# MQTT 配置
MQTT_BROKER = "127.0.0.1"
MQTT_PORT = 1883
MQTT_QOS = 1
MQTT_TOPIC_SUB = "node/status"
MQTT_TOPIC_PUB = "node/{node_id}/status"

# 内嵌 Broker 配置
# 业务环境同样启用，外部访问通过 frp 反代实现
EMBEDDED_BROKER = True
BROKER_BIND_HOST = "0.0.0.0"  # 监听所有网卡，便于 frp 反代和局域网访问
BROKER_BIND_PORT = 1883

# 心跳与看门狗
HEARTBEAT_TIMEOUT = 600  # 秒，节点心跳超时时间
WATCHDOG_INTERVAL = 30   # 秒，看门狗检查间隔

# 消息格式
MSG_LENGTH = 7
NODE_ID_LENGTH = 5

# 路径（相对于 src/ 目录）
LOG_DIR = "log"
AUDIO_DIR = "resources/audio"

# 音频文件映射
AUDIO_FILES = {
    # 系统上下线语音播报
    "sys_online": "SYS_ONLINE.wav",
    "sys_offline": "SYS_OFFLINE.wav",
    # 游戏事件
    "game_started": "GAME_START.wav",
    "game_stopped": "GAME_STOP.wav",
    # 节点激活提示（每个队伍不同音效）
    "activated_A": "TEAM_A_READY.wav",
    "activated_B": "TEAM_B_READY.wav",
    "activated_C": "TEAM_C_READY.wav",
    "activated_D": "TEAM_D_READY.wav",
    # 队伍淘汰（队伍特定）
    "eliminated_A": "TEAM_A_ELI.wav",
    "eliminated_B": "TEAM_B_ELI.wav",
    "eliminated_C": "TEAM_C_ELI.wav",
    "eliminated_D": "TEAM_D_ELI.wav",
    # 队伍胜利（队伍特定）
    "victory_A": "TEAM_A_WIN.wav",
    "victory_B": "TEAM_B_WIN.wav",
    "victory_C": "TEAM_C_WIN.wav",
    "victory_D": "TEAM_D_WIN.wav",
    # 爆破模式胜利
    "victory_T": "TEAM_T_WIN.wav",
    "victory_CT": "TEAM_CT_WIN.wav",
    # 炸弹事件
    "bomb_activated": "BOOM_PLANTED.wav",
    "bomb_defused": "BOOM_DEFUSED.wav",
}
