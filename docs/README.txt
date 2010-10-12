
# Pickels Web Framework

## Pickles とは？

Sledge を微妙に意識した、Web Application Framework です。以下のような点が特徴です。

* PSGI/Plack を使用
* Moose や Mouse を使わない
* 挙動のカスタマイズは Class::Trigger によるフック関数の実行とベタな継承を使う
* 一応、簡単なプラグイン機構を備える

## インストール ##

いつもと一緒です。

    % perl Makefile.PL
    % make
    # make install

## Hello World! ##

インストールすると pickles-setup コマンドがインストールされます。

 % pickles-setup MyApp

Module::Setup を使用しているので、名前とかメールアドレスとか聞かれます。

MyApp に以下のようなレイアウトでファイル群が作られます。

    MyApp/
        Changes
        MANIFEST.SKIP
        Makefile.PL
        README
        MyApp.psgi 
        config.pl - 設定ファイル
            htdocs/ - 静的ファイル
            lib/ - アプリケーション本体
                MyApp.pm 
                MyApp/
                    Config.pm
                    Context.pm
                    Dispatcher.pm
                    View.pm
                Controller/
                    Root.pm
            t/ - テスト
            view/ - テンプレート類
            xt/ - 開発者用テスト


インストール時点では View を表示するだけのアプリケーションが http://localhost:5000/ で立ち上がります。

    % cd MyApp
    % plackup -I./lib app.psgi

## アプリケーションの書き方 ##

基本的な流れは

1. MyApp::Dispatcher を更新し、URL に対応した Controller と action を指定
2. MyApp::Controller::* を追加、更新して実際のロジックを記述
3. その他必要に応じてプラグインのロード、モデルの登録等を MyApp::Context に記述

### MyApp::Dispatcher ###

自動生成されたファイルは以下のようになっています。
パスとコントローラーの対応を記述します。

    package MyApp::Dispatcher;
    use strict;
    use base qw(Pickles::Dispatcher);
    
    __PACKAGE__->routes(
        '/' => { controller => 'Root', action => 'index' } 
    );
 
    1;
    
    __END__

内部的には Router::Simple を使っています。
引数を使用する場合は以下のように記述します。
引数は $c->args で Hash-Ref としてアクセス出来ます。

    __PACKAGE__->routes(
        '/view/:id' => { controller => 'Root', action => 'index' },
    );


### Config ###

設定ファイルは MyApp/config.pl を使用します。設定の切り替えは環境変数を参照して行います。
config.pl は存在したら常に読み込まれます。
その後、以下の環境変数を順番に参照し、ハッシュがマージされます。



環境変数 $ENV{'MYAPP_ENV'} が存在する場合は config_${'MYAPP_ENV'}.pl と suffix をつけた設定ファイルが読み込まれます。



### Controller ###

    package MyApp::Controller::Root;
    use strict;
    use warnings;
    use parent 'Pickles::Controller';
    
    sub index {
        my( $self, $c ) = @_; # $c is-a MyApp::Context
    }
     
    1;
    
    __END__

### Context ###

    package MyApp::Context;
     
    use strict;
    use warnings;
    use parent 'Pickles::Context';
     
    __PACKAGE__->load_plugins(qw(Encode));
    
    1;
    
    __END__

デフォルトでは文字エンコーディングを適切に取り扱うための Pickles::Plugin::Encode をロードしています。

Context は以下のメソッドを実装しています。



挙動のカスタマイズは Context を拡張する事によって行います。
Context の拡張は主に継承によるメソッドの追加、オーバーライド、Class::Trigger によるフック関数の実行によって行います。

*** Object Container としての挙動

Pickles は Model の機構を持ちませんが、コードを書きやすくするため、Context が Object Container として振る舞う事が出来ます。






