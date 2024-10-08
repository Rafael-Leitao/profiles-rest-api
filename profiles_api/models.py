from django.db import models
from django.contrib.auth.models import AbstractBaseUser
from django.contrib.auth.models import PermissionsMixin
from django.contrib.auth.models import BaseUserManager
from django.conf import settings


class UserProfileManager(BaseUserManager):
    """ Manager for user profiles """
    def create_user(self, email, name, password=None):
        """ Create a new user profile"""
        if not email:
            raise ValueError('Users must have an email address')
        
        email = self.normalize_email(email)
        user = self.model(email=email, name=name)
        user.set_password(password)
        user.save(using=self._db)
        return user
    
    def create_superuser(self, email, name, password):
        """ Create a new super user with given details"""
        user = self.create_user(email, name, password)
        user.is_superuser = True
        user.is_staff = True
        user.save(using=self._db)

        return user


class UserProfile(AbstractBaseUser, PermissionsMixin):
    """Database model for users in the system"""
    email = models.EmailField(max_length=255, unique=True)
    name = models.CharField(max_length=255)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    objects = UserProfileManager() #Class will be created later
    USERNAME_FIELD = 'email' #To override the default username. This is REQUIRED.
    REQUIRED_FIELDS = ['name'] #To specify the fields that are required when creating a new user


    def get_full_name(self):
        """Get the full name of the user"""
        return self.name
    
    def get_short_name(self):
        """Get the short name of the user"""
        return self.name
    
    def __str__(self):
        """Return a string representation of the user"""
        return self.email
    

class ProfileFeedItem(models.Model):
    """Profile status update"""
    user_profile = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    status_text = models.CharField(max_length=255)
    created_on = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        """Return a string representation of the status"""
        return self.status_text
    