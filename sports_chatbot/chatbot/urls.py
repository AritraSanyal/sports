from django.urls import path
from .views import chat

urlpatterns = [
    path('api/chat/', chat, name='chat'),  #important for postman
]
