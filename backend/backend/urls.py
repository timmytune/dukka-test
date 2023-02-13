"""backend URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import include, path
from rest_framework import routers
from tracker.views import CurrentUser, JourneyDetail, JourneyList, MovementList, MovementDetail, PointList, PointDetail, UserList

from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView, TokenVerifyView


# router = routers.DefaultRouter()
# router.register(r'journey', Journey)

# Wire up our API using automatic URL routing.
# Additionally, we include login URLs for the browsable API.
urlpatterns = [
    path('super/', admin.site.urls),
    path('api/v1/user', CurrentUser.as_view(), name='user'),
    path('api/v1/journey/', JourneyList.as_view()),
    path('api/v1/journey/<int:pk>/', JourneyDetail.as_view()),
    path('api/v1/movement/', MovementList.as_view()),
    path('api/v1/movement/<int:pk>/', MovementDetail.as_view()),
    path('api/v1/point/', PointList.as_view()),
    path('api/v1/point/<int:pk>/', PointDetail.as_view()),
    #path('api-auth/', include('rest_framework.urls', namespace='rest_framework')),
    path('api/register/', UserList.as_view(), name='register'),
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/token/verify/', TokenVerifyView.as_view(), name='token_verify'),
]


