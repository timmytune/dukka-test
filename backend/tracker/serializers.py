from django.contrib.auth.models import User, Group
from rest_framework import serializers
from rest_framework_simplejwt.tokens import RefreshToken
from tracker.models import Journey, Movement, Point

'''
    Seriializer that works with the Django User Model
'''
class UserSerializer(serializers.ModelSerializer):
    #journeys = serializers.PrimaryKeyRelatedField(many=True, queryset=Journey.objects.all())
    class Meta:
        model = User
        fields = [ 'id', 'password', 'username', 'email', 'groups']
        #extra_kwargs = {'password': {'write_only': True}}

    # Returns user token
    def get_tokens(self, user):
        tokens = RefreshToken.for_user(user)
        refresh = str(tokens)
        access = str(tokens.access_token)
        data = {
            "refresh": refresh,
            "access": access
        }
        return data

    # Creates new User
    def create(self, validated_data):
        user = User(email=validated_data['email'], username = validated_data['username'])
        print(validated_data)
        user.set_password(validated_data['password'])
        user.save()    
        return user


'''
    Seriializer that works with the Django Group Model
'''
class GroupSerializer(serializers.ModelSerializer):
    class Meta:
        model = Group
        fields = ['id', 'name']


'''
    Seriializer that works with User journey
'''
class JourneySerializer(serializers.ModelSerializer):

    user = serializers.ReadOnlyField(source='user.id')

    class Meta:
        model = Journey
        fields = [ 'id', 'name', 'description', 'created', 'ended_at', 'user']

'''
    Seriializer that works with User Movement
'''
class MovementSerializer(serializers.ModelSerializer):

    user = serializers.ReadOnlyField(source='user.id')
    journey = serializers.ReadOnlyField(source='journey.id')

    class Meta:
        model = Movement
        fields = [ 'id', 'created', 'ended_at', 'user', 'journey']

'''
    Seriializer that works with the Django point location
'''

class PointSerializer(serializers.ModelSerializer):

    user = serializers.ReadOnlyField(source='user.id')
    movement = serializers.ReadOnlyField(source='movement.id')

    class Meta:
        model = Point
        fields = [ 'id', 'created', 'lon', 'lat', 'user', 'movement']

