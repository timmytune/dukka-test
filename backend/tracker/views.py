import logging
import traceback

from django.contrib.auth.models import User
from rest_framework import viewsets, permissions, mixins, generics, exceptions, status
from django.http.response import Http404
from rest_framework.views import APIView
from rest_framework.response import Response

import logging
import traceback



from tracker.models import Journey, Movement, Point

from tracker.permissions import IsOwnerOrReadOnly

from tracker.serializers import UserSerializer, JourneySerializer, MovementSerializer, PointSerializer



class UserList(generics.ListAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def perform_create(self, serializer):
        return serializer.create(serializer.data)

    def post(self, request, *args, **kwargs):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            user = self.perform_create(serializer)
            tokens = serializer.get_tokens(user)
            return Response(tokens, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    
class CurrentUser(APIView):
    """
        API endpoint that retrieves current user.
    """

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, format=None):

        try:
            serializer_context = {
                'request': request,
            }
            user = UserSerializer(instance=request.user, context=serializer_context)
            return Response(user.data)
        except User.DoesNotExist:
            return exceptions.bad_request(request=request, exception=User.DoesNotExist)


class JourneyList(mixins.ListModelMixin, mixins.CreateModelMixin, generics.GenericAPIView):
    
    queryset = Journey.objects.all()
    serializer_class = JourneySerializer

    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
    
    def get(self, request, *args, **kwargs):
        if request.query_params and 'current_user' in request.query_params: 
            try:
                serializer_context = {
                    'request': request,
                }
                journeys = Journey.objects.get(user=request.user)
                journeys_serialized = JourneySerializer(instance=journeys, context=serializer_context)
                return Response(journeys_serialized.data)

            except Exception as e:
                    logging.error(traceback.format_exc())
                    return exceptions.bad_request(request, e)
        else:    

            return self.list(request, *args, **kwargs)

    def post(self, request, *args, **kwargs):
        try:
            return self.create(request, *args, **kwargs)
        except Exception as e: 
            return exceptions.bad_request(request, e)



class JourneyDetail(mixins.RetrieveModelMixin, mixins.UpdateModelMixin, mixins.DestroyModelMixin, generics.GenericAPIView):


    queryset = Journey.objects.all()
    serializer_class = JourneySerializer

    permission_classes = [permissions.IsAuthenticated, IsOwnerOrReadOnly]

    def perform_update(self, serializer):
        return serializer.save(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
    
    
    def get(self, request, *args, **kwargs):
        try:
            return self.retrieve(request, *args, **kwargs)
        except Exception as e: 
            return exceptions.bad_request(request, e)


    def put(self, request, *args, **kwargs):
        try:
            return self.update(request, *args, **kwargs)
        except Exception as e: 
            return exceptions.bad_request(request, e)

    def delete(self, request, *args, **kwargs):
        try:
            return self.delete(request, *args, **kwargs)
        except Exception as e: 
            return exceptions.bad_request(request, e)




class MovementList(mixins.ListModelMixin, mixins.CreateModelMixin, generics.GenericAPIView):
    
    queryset = Movement.objects.all()
    serializer_class = MovementSerializer

    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        if self.request.data and 'journey_id' in self.request.data:
            serializer.save(user=self.request.user, journey_id = self.request.data['journey_id'])
        else:
            serializer.save(user=self.request.user)

    def get(self, request, *args, **kwargs):
        if request.query_params and 'current_user' in request.query_params: 
            try:
                serializer_context = {
                    'request': request,
                }
                movements = Movement.objects.get(user=request.user)
                movements_serialized = MovementSerializer(instance=movements, context=serializer_context)
                return Response(movements_serialized.data)

            except Exception as e:
                    logging.error(traceback.format_exc())
                    return exceptions.bad_request(request, e)
        else:    

            return self.list(request, *args, **kwargs)

    def post(self, request, *args, **kwargs):
        try:
            return self.create(request, *args, **kwargs)
        except Exception as e: 
            return exceptions.bad_request(request, e)


class MovementDetail(mixins.RetrieveModelMixin, mixins.UpdateModelMixin, mixins.DestroyModelMixin, generics.GenericAPIView):


    queryset = Movement.objects.all()
    serializer_class = MovementSerializer

    permission_classes = [permissions.IsAuthenticated, IsOwnerOrReadOnly]

    def perform_update(self, serializer):
        return serializer.save(user=self.request.user)
    
    def get(self, request, *args, **kwargs):
        try:
            return self.retrieve(request, *args, **kwargs)
        except Exception as e: 
            return exceptions.bad_request(request, e)

    def put(self, request, *args, **kwargs):
        try:
            return self.update(request, *args, **kwargs)
        except Exception as e: 
            print(e)
            return exceptions.bad_request(request, e)

    def delete(self, request, *args, **kwargs):
        try:
            return self.delete(request, *args, **kwargs)
        except Exception as e: 
            return exceptions.bad_request(request, e)



class PointList(mixins.ListModelMixin, mixins.CreateModelMixin, generics.GenericAPIView):
    
    queryset = Point.objects.all()
    serializer_class = PointSerializer

    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        try: 
            serializer.save(user=self.request.user, movement_id=self.request.data['movement'])
        except Exception as e:
            logging.error(traceback.format_exc())
            return exceptions.bad_request(self.request, e)
    
    def get(self, request, *args, **kwargs):
        if request.query_params and 'current_user' in request.query_params: 
            try:
                serializer_context = {
                    'request': request,
                }
                points = Point.objects.get(user=request.user)
                points_serialized = PointSerializer(instance=points, context=serializer_context)
                return Response(points_serialized.data)

            except Exception as e:
                    logging.error(traceback.format_exc())
                    return exceptions.bad_request(request, e)
        else:    

            return self.list(request, *args, **kwargs)

    def post(self, request, *args, **kwargs):
        try:
            return self.create(request, *args, **kwargs)
        except Exception as e: 
            return exceptions.bad_request(request, e)



class PointDetail(mixins.RetrieveModelMixin, mixins.UpdateModelMixin, mixins.DestroyModelMixin, generics.GenericAPIView):


    queryset = Point.objects.all()
    serializer_class = PointSerializer

    permission_classes = [permissions.IsAuthenticated, IsOwnerOrReadOnly]

    def perform_update(self, serializer):
        return serializer.save(user=self.request.user)
    
    def get(self, request, *args, **kwargs):
        try:
            return self.retrieve(request, *args, **kwargs)
        except Exception as e: 
            return exceptions.bad_request(request, e)


    def put(self, request, *args, **kwargs):
        try:
            return self.update(request, *args, **kwargs)
        except Exception as e: 
            return exceptions.bad_request(request, e)

    def delete(self, request, *args, **kwargs):
        try:
            return self.destroy(request, *args, **kwargs)
        except Exception as e: 
            return exceptions.bad_request(request, e)

