---
layout: default
title: Sally's Adventures
---

<ul class="posts">
  {% for post in site.posts %}
    <li><a href="{{ post.url }}">{{ post.title }} ({{ post.date | date: "%B %d, %Y" }})</a></li>
  {% endfor %}
</ul>
