# Generated by Django 4.1.5 on 2023-04-08 06:56

from django.conf import settings
import django.contrib.postgres.fields
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='Poll',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('title', models.CharField(max_length=100, verbose_name='Poll title')),
                ('description', models.CharField(blank=True, max_length=255, verbose_name='Description')),
            ],
            options={
                'permissions': (('edit_poll', 'Can edit poll'), ('answer_poll', 'Can answer a poll')),
            },
        ),
        migrations.CreateModel(
            name='PollCharField',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('text', models.CharField(max_length=100, verbose_name='Question Text')),
                ('poll', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='polls.poll')),
            ],
        ),
        migrations.CreateModel(
            name='PollChoiceField',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('text', models.CharField(max_length=100, verbose_name='Question Text')),
                ('choices', django.contrib.postgres.fields.ArrayField(base_field=models.CharField(max_length=100, verbose_name='Choice'), size=None)),
                ('poll', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='polls.poll')),
            ],
        ),
        migrations.CreateModel(
            name='PollMultiChoiceField',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('text', models.CharField(max_length=100, verbose_name='Question Text')),
                ('choices', django.contrib.postgres.fields.ArrayField(base_field=models.CharField(max_length=100, verbose_name='Choice'), size=None)),
                ('poll', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='polls.poll')),
            ],
        ),
        migrations.CreateModel(
            name='PollTextField',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('text', models.CharField(max_length=100, verbose_name='Question Text')),
                ('poll', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='polls.poll')),
            ],
        ),
        migrations.CreateModel(
            name='PollTextFieldAnswer',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('answer', models.TextField(verbose_name='Answer')),
                ('field', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='text_field_answers', related_query_name='text_field_answer', to='polls.polltextfield')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'unique_together': {('user', 'field')},
            },
        ),
        migrations.CreateModel(
            name='PollMultiChoiceFieldAnswer',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('selected_choices', django.contrib.postgres.fields.ArrayField(base_field=models.CharField(max_length=100, verbose_name='Selected Choices'), size=None)),
                ('field', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='multichoice_field_answers', related_query_name='multichoice_field_answer', to='polls.pollmultichoicefield')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'unique_together': {('user', 'field')},
            },
        ),
        migrations.CreateModel(
            name='PollChoiceFieldAnswer',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('selected_choice', models.CharField(max_length=100, verbose_name='Selected Choice')),
                ('field', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='choice_field_answers', related_query_name='choice_field_answer', to='polls.pollchoicefield')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'unique_together': {('user', 'field')},
            },
        ),
        migrations.CreateModel(
            name='PollCharFieldAnswer',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('answer', models.CharField(max_length=100, verbose_name='Answer')),
                ('field', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='char_field_answers', related_query_name='char_field_answer', to='polls.pollcharfield')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'unique_together': {('user', 'field')},
            },
        ),
    ]
