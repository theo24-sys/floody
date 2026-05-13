import json
from channels.generic.websocket import AsyncWebsocketConsumer

class ReportConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        await self.channel_layer.group_add("reports", self.channel_name)
        await self.accept()

    async disconnect(self, close_code):
        await self.channel_layer.group_discard("reports", self.channel_name)

    async report_update(self, event):
        await self.send(text_data=json.dumps(event["message"]))
