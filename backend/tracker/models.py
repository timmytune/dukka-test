from django.db import models
#from django.contrib.gis.db import models as models2
from django.contrib.auth.models import User

'''
    Journey model:  responsible for storing user journies as a collection of movements
'''
class Journey(models.Model):

    user = models.ForeignKey(User, on_delete=models.CASCADE)

    name = models.CharField(max_length=100, blank=True, default='')
    description = models.CharField(max_length=1000, blank=True, default='')
    created = models.DateTimeField(auto_now_add=True)
    ended_at = models.DateTimeField(blank=True, null=True)

    class Meta:
        ordering = ['created']

'''
    Movement Model: responsible for storing the individual movements of a user as a collections of points
'''

class Movement(models.Model):

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    journey = models.ForeignKey(Journey, on_delete=models.CASCADE, null=True, blank=True)

    created = models.DateTimeField(auto_now_add=True)
    ended_at = models.DateTimeField(blank=True, null=True)

    class Meta:
        ordering = ['created']

'''
    Point Model: this stores the individual locations of a user in longtitude and latitude with the time the user was there

'''

class Point(models.Model):

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    movement = models.ForeignKey(Movement, on_delete=models.CASCADE)

    created = models.DateTimeField()
    lon = models.FloatField(blank=False)
    lat = models.FloatField(blank=False)

    class Meta:
        ordering = ['created']