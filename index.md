---
layout: default
title: Little Sally
---

<ul class="posts">
  {% for post in site.categories.development %}
    <li><a href="{{ post.url }}">{{ post.title }}</a></li>
  {% endfor %}
</ul>
