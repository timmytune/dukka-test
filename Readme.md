# DUKKA Location tracker app test

In this repository is the implementation of the tracker app and backend. Take note though this could be better with more time and is only intended to show the specific functions requested -:)

## Backend

The backend is a django service that uses rest framework. There are three new models in additionon to the ones from django

1. Point: This stands for a single point the user has been to at a specific time
2. Movement: This stands for a collection of points that shows the movewment of the user from one place to another
3. Journey: This is a colection of movements that are significant to the user

All three models are creatatable and updatable from the API

### Setup

1. Clone repo
2. Cd into project backend directory
3. Run `pip install django psycopg2-binary` (if you don't already have django installed)
4. Run `pip install djangorestframework djangorestframework-simplejwt`
5. Open `./backend/settings.py` and update the postgres database settings to your own
6. Run `python manage.py migrate` to run the database setup
7. Run `python manage.py createsuperuser` to create super user
8. Then run `python manage.py runserver 0.0.0.0:8000` to run the backend locally

You can test the API with postman collection https://documenter.getpostman.com/view/3507920/2s935vjzUt

## Frontend

Tracking a users movement requires they have a device they can move with so the only frontend that can be used for that is Flutter. The frontend tracks the user's movement from a background process and periodically uploads the co-ordiates as points to the backend. Also the frontend is responsible for tracking which movement in the backend to add the points to. To run the code, run the frontend folder in andoid studio or vs code. The App authomatically comnects to http://44.211.16.5:8000 that currently hosts the app so you can test.
