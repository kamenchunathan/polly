# Generated by Django 4.1.5 on 2023-01-11 21:53

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('polls', '0002_remove_pollcharfield_answer_and_more'),
    ]

    operations = [
        migrations.RenameField(
            model_name='pollcharfield',
            old_name='question_text',
            new_name='text',
        ),
        migrations.RenameField(
            model_name='pollchoicefield',
            old_name='question_text',
            new_name='text',
        ),
        migrations.RenameField(
            model_name='pollmultichoicefield',
            old_name='question_text',
            new_name='text',
        ),
        migrations.RenameField(
            model_name='polltextfield',
            old_name='question_text',
            new_name='text',
        ),
    ]
