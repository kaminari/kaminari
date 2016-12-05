# Kaminari [![Build Status](https://travis-ci.org/amatsuda/kaminari.svg)](http://travis-ci.org/amatsuda/kaminari) [![Code Climate](https://img.shields.io/codeclimate/github/amatsuda/kaminari.svg)](https://codeclimate.com/github/amatsuda/kaminari) [![Inch CI](http://inch-ci.org/github/amatsuda/kaminari.svg)](http://inch-ci.org/github/amatsuda/kaminari)

A Scope & Engine based, clean, powerful, customizable and sophisticated paginator for modern web app frameworks and ORMs

## Features

### Clean
Does not globally pollute `Array`, `Hash`, `Object` or `AR::Base`.

### Easy to Use
Just bundle the gem, then your models are ready to be paginated.
No configuration required.
Don't have to define anything in your models or helpers.

### Simple Scope-based API
Everything is method chainable with less "Hasheritis". You know, that's the modern Rails way.
No special collection class or anything for the paginated values, instead using a general `AR::Relation` instance.
So, of course you can chain any other conditions before or after the paginator scope.

### Customizable Engine-based I18n-aware Helpers
As the whole pagination helper is basically just a collection of links and non-links, Kaminari renders each of them through its own partial template inside the Engine.
So, you can easily modify their behaviour, style or whatever by overriding partial templates.

### ORM & Template Engine Agnostic
Kaminari supports multiple ORMs (ActiveRecord, DataMapper, Mongoid, MongoMapper) multiple web frameworks (Rails, Sinatra, Grape), and multiple template engines (ERB, Haml, Slim).

### Modern
The pagination helper outputs the HTML5 `<nav>` tag by default. Plus, the helper supports Rails unobtrusive Ajax.


## Supported Versions

* Ruby 2.0.0, 2.1.x, 2.2.x, 2.3.x, 2.4

* Rails 4.1, 4.2, 5.0, 5.1

* Sinatra 1.4

* Haml 3+

* Mongoid 3+

* MongoMapper 0.9+

* DataMapper 1.1.0+


## Installation

Put this line in your Gemfile:

    gem 'kaminari'

Then bundle:

    % bundle


## Query Basics

### The `page` Scope

To fetch the 7th page of users (default `per_page` is 25)

    User.page(7)

Note: pagination starts at page 1, not at page 0 (page(0) will return the same results as page(1)).

### The `per` Scope

To show a lot more users per each page (change the `per_page` value)

    User.page(7).per(50)

Note that the `per` scope is not directly defined on the models but is just a method defined on the page scope.
This is absolutely reasonable because you will never actually use `per_page` without specifying the `page` number.

Keep in mind that `per` internally utilizes `limit` and so it will override any `limit` that was set previously.
And if you want get size for all request records you can use `total_count` method:

    User.count                    # => 1000
    a = User.limit(5); a.count    # => 5
    a.page(1).per(20).size        # => 20
    a.page(1).per(20).total_count # => 1000

### The `padding` Scope

Occasionally you need to pad a number of records that is not a multiple of the page size.

    User.page(7).per(50).padding(3)

Note that the `padding` scope also is not directly defined on the models.

## General Configuration Options

You can configure the following default values by overriding these values using `Kaminari.configure` method.

    default_per_page      # 25 by default
    max_per_page          # nil by default
    max_pages             # nil by default
    window                # 4 by default
    outer_window          # 0 by default
    left                  # 0 by default
    right                 # 0 by default
    page_method_name      # :page by default
    param_name            # :page by default
    params_on_first_page  # false by default

There's a handy generator that generates the default configuration file into config/initializers directory.
Run the following generator command, then edit the generated file.

    % rails g kaminari:config

### Changing `page_method_name`

You can change the method name `page` to `bonzo` or `plant` or whatever you like, in order to play nice with existing `page` method or association or scope or any other plugin that defines `page` method on your models.

## Configuring Default per_page Value for Each Model

### `paginates_per`

You can specify default `per_page` value per each model using the following declarative DSL.

    class User < ActiveRecord::Base
      paginates_per 50
    end

## Configuring Max per_page Value for Each Model

### `max_paginates_per`

You can specify max `per_page` value per each model using the following declarative DSL.
If the variable that specified via `per` scope is more than this variable, `max_paginates_per` is used instead of it.
Default value is nil, which means you are not imposing any max `per_page` value.

    class User < ActiveRecord::Base
      max_paginates_per 100
    end

## Controllers

### The Page Parameter Is in `params[:page]`

Typically, your controller code will look like this:

    @users = User.order(:name).page params[:page]


## Views

### The Same Old Helper Method

Just call the `paginate` helper:

    <%= paginate @users %>

This will render several `?page=N` pagination links surrounded by an HTML5 `<nav>` tag.


## Helpers

### The `paginate` Helper Method

    <%= paginate @users %>

This would output several pagination links such as `« First ‹ Prev ... 2 3 4 5 6 7 8 9 10 ... Next › Last »`

### Specifying the "inner window" Size (4 by default)

    <%= paginate @users, window: 2 %>

This would output something like `... 5 6 7 8 9 ...` when 7 is the current
page.

### Specifying the "outer window" Size (0 by default)

    <%= paginate @users, outer_window: 3 %>

This would output something like `1 2 3 4 ...(snip)... 17 18 19 20` while having 20 pages in total.

### Outer Window Can Be Separately Specified by left, right (0 by default)

    <%= paginate @users, left: 1, right: 3 %>

This would output something like `1 ...(snip)... 18 19 20` while having 20 pages in total.

### Changing the Parameter Name (`:param_name`) for the Links

    <%= paginate @users, param_name: :pagina %>

This would modify the query parameter name on each links.

### Extra Parameters (`:params`) for the Links

    <%= paginate @users, params: {controller: 'foo', action: 'bar'} %>

This would modify each link's `url_option`. :`controller` and :`action` might be the keys in common.

### Ajax Links (crazy simple, but works perfectly!)

    <%= paginate @users, remote: true %>

This would add `data-remote="true"` to all the links inside.

### Specifying an Alternative Views Directory (default is kaminari/)

    <%= paginate @users, views_prefix: 'templates' %>

This would search for partials in `app/views/templates/kaminari`.
This option makes it easier to do things like A/B testing pagination templates/themes, using new/old templates at the same time as well as better integration with other gems such as [cells](https://github.com/apotonick/cells).

### The `link_to_next_page` and `link_to_previous_page` Helper Methods

    <%= link_to_next_page @items, 'Next Page' %>

This simply renders a link to the next page. This would be helpful for creating a Twitter-like pagination feature.

### The `page_entries_info` Helper Method

    <%= page_entries_info @posts %>

This renders a helpful message with numbers of displayed vs. total entries.

By default, the message will use the humanized class name of objects in collection: for instance, "project types" for ProjectType models.
The namespace will be cut out and only the last name will be used. Override this with the `:entry_name` parameter:

    <%= page_entries_info @posts, entry_name: 'item' %>
    #=> Displaying items 6 - 10 of 26 in total

### The `rel_next_prev_link_tags` Helper Method

    <%= rel_next_prev_link_tags @users %>

This renders the rel next and prev link tags for the head.

### The `path_to_next_page` Helper Method

    <%= path_to_next_page @users %>

This returns the server relative path to the next page.

### The `path_to_prev_page` Helper Method

    <%= path_to_prev_page @users %>

This returns the server relative path to the previous page.

## I18n and Labels

The default labels for 'first', 'last', 'previous', '...' and 'next' are stored in the I18n yaml inside the engine, and rendered through I18n API.
You can switch the label value per I18n.locale for your internationalized application.  Keys and the default values are the following. You can override them by adding to a YAML file in your `Rails.root/config/locales` directory.

    en:
      views:
        pagination:
          first: "&laquo; First"
          last: "Last &raquo;"
          previous: "&lsaquo; Prev"
          next: "Next &rsaquo;"
          truncate: "&hellip;"
      helpers:
        page_entries_info:
          one_page:
            display_entries:
              zero: "No %{entry_name} found"
              one: "Displaying <b>1</b> %{entry_name}"
              other: "Displaying <b>all %{count}</b> %{entry_name}"
          more_pages:
            display_entries: "Displaying %{entry_name} <b>%{first}&nbsp;-&nbsp;%{last}</b> of <b>%{total}</b> in total"

If you use non-English localization see [i18n rules](https://github.com/svenfuchs/i18n/blob/f19893d84262261d9c8abe303f465ea28ba057e4/test/test_data/locales/plurals.rb) for changing
`one_page:display_entries` block.

## Customizing the Pagination Helper

Kaminari includes a handy template generator.

### To Edit Your Paginator

Run the generator first,

    % rails g kaminari:views default

then edit the partials in your app's `app/views/kaminari/` directory.

### For Haml/Slim Users

You can use the [html2haml gem](https://github.com/haml/html2haml) or the [html2slim gem](https://github.com/slim-template/html2slim) to convert erb templates.
The kaminari gem will automatically pick up haml/slim templates if you place them in `app/views/kaminari/`.

### Multiple Templates

In case you need different templates for your paginator (for example public and admin), you can pass `--views-prefix directory` like this:

    % rails g kaminari:views default --views-prefix admin

that will generate partials in `app/views/admin/kaminari/` directory.

### Themes

The generator has the ability to fetch several sample template themes from the external repository (https://github.com/amatsuda/kaminari_themes) in addition to the bundled "default" one, which will help you creating a nice looking paginator.

    % rails g kaminari:views THEME

To see the full list of available themes, take a look at the themes repository, or just hit the generator without specifying `THEME` argument.

    % rails g kaminari:views

### Multiple Themes

To utilize multiple themes from within a single application, create a directory within the app/views/kaminari/ and move your custom template files into that directory.

    % rails g kaminari:views default (skip if you have existing kaminari views)
    % cd app/views/kaminari
    % mkdir my_custom_theme
    % cp _*.html.* my_custom_theme/

Next, reference that directory when calling the `paginate` method:

    <%= paginate @users, theme: 'my_custom_theme' %>

Customize away!

Note: if the theme isn't present or none is specified, kaminari will default back to the views included within the gem.


## Paginating a Generic Array object

Kaminari provides an Array wrapper class that adapts a generic Array object to the `paginate` view helper. However, the `paginate` helper doesn't automatically handle your Array object (this is intentional and by design).
`Kaminari::paginate_array` method converts your Array object into a paginatable Array that accepts `page` method.

    @paginatable_array = Kaminari.paginate_array(my_array_object).page(params[:page]).per(10)

You can specify the `total_count` value through options Hash. This would be helpful when handling an Array-ish object that has a different `count` value from actual `count` such as RSolr search result or when you need to generate a custom pagination. For example:

    @paginatable_array = Kaminari.paginate_array([], total_count: 145).page(params[:page]).per(10)

## Creating Friendly URLs and Caching

Because of the `page` parameter and Rails routing, you can easily generate SEO and user-friendly URLs. For any resource you'd like to paginate, just add the following to your `routes.rb`:

    resources :my_resources do
      get 'page/:page', action: :index, on: :collection
    end

If you are using Rails 4 or later, you can simplify route definitions by using `concern`:

    concern :paginatable do
      get '(page/:page)', action: :index, on: :collection, as: ''
    end

    resources :my_resources, concerns: :paginatable

This will create URLs like `/my_resources/page/33` instead of `/my_resources?page=33`. This is now a friendly URL, but it also has other added benefits...

Because the `page` parameter is now a URL segment, we can leverage on Rails [page caching](http://guides.rubyonrails.org/caching_with_rails.html#page-caching)!

NOTE: In this example, I've pointed the route to my `:index` action. You may have defined a custom pagination action in your controller - you should point `action: :your_custom_action` instead.

## Sinatra/Padrino Support

See: https://github.com/kaminari/kaminari-sinatra

## Grape Support

See: https://github.com/kaminari/kaminari-grape

## For More Information

Check out Kaminari recipes on the GitHub Wiki for more advanced tips and techniques. https://github.com/amatsuda/kaminari/wiki/Kaminari-recipes

## Questions, Feedback

Feel free to message me on Github (amatsuda) or Twitter ([@a_matsuda](https://twitter.com/a_matsuda))  ☇☇☇  :)

## Contributing to Kaminari

Fork, fix, then send a pull request.

To run the test suite locally against all supported frameworks:

    % bundle install
    % rake spec:all

To target the test suite against one framework:

    % rake spec:active_record_41

You can find a list of supported spec tasks by running `rake -T`. You may also find it useful to run a specific test for a specific framework. To do so, you'll have to first make sure you have bundled everything for that configuration, then you can run the specific test:

    % BUNDLE_GEMFILE='gemfiles/active_record_41.gemfile' bundle install
    % BUNDLE_GEMFILE='gemfiles/active_record_41.gemfile' bundle exec rspec ./spec/requests/users_spec.rb

## Copyright

Copyright (c) 2011 Akira Matsuda. See MIT-LICENSE for further details.
