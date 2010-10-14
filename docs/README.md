
# Pickels Web Framework

## Pickles とは？

Sledge を微妙に意識した、Web Application Framework です。以下のような点が特徴です。

* PSGI/Plack を使用
* Moose や Mouse を使わない
* Model の仕組みは押しつけない
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
2. MyApp::Controller::* を追加、編集して実際のロジックを記述
3. その他必要に応じてプラグインのロード、モデルの登録等を MyApp::Context に記述

### Dispatcher ###

自動生成されたファイルは以下のようになっています。
パスと Controller, action の対応を記述します。

    package MyApp::Dispatcher;
    use strict;
    use base qw(Pickles::Dispatcher);
    
    __PACKAGE__->routes(
        '/' => { controller => 'Root', action => 'index' } 
    );
 
    1;
    
    __END__

内部的には Router::Simple を使っています。
パスの一部を引数として使用する場合は $c->args で Hash-Ref としてアクセス出来ます。

    __PACKAGE__->routes(
        '/' => { controller => 'Root', action => 'index' } 
        '/view/:id' => { controller => 'Root', action => 'view' },
    );

### Controller ###

    package MyApp::Controller::Root;
    use strict;
    use warnings;
    use parent 'Pickles::Controller';
    
    sub index {
        my( $self, $c ) = @_; # $c is-a MyApp::Context
    }
    
    sub view {
        my( $self, $c ) = @_;
        my $id = $c->args->{id};
        # ...
    }
     
    1;
    
    __END__

### Config ###

設定ファイルとして HASH-Ref を返す .pl ファイルを使用します。デフオルトでは MyApp/config.pl が読み込まれます。
シングルトンとして実装されており、Webアプリケーション、バッチを問わずにどこからでも利用する事が出来ます。
値へのアクセスは get メソッドを利用するか、HASH-Ref として直接アクセスする事も出来ます。get メソッドの場合は第2引数でデフォルト値を指定する事が出来ます。

    my $config = MyApp::Config->instance;
    my $val = $config->get('foo', 2); # デフォルト値を指定
    my $val = $config->{'foo'};

#### HOME ####

デフォルトでは pickles-setup で作成した MyApp 直下がHOMEとなり、アプリケーションで使用するあらゆるファイルはHOMEの下に配置します。
通常はHOMEを明示的に指定する必要は無いでしょう。
アプリケーションを make install した場合等、アプリケーションのHOMEを明示的に指定したい場合は $ENV{'MYAPP_HOME'} もしくは $ENV{'PICKLES_HOME'} という環境変数に HOMEを絶対パスで指定します。
HOMEの値は $config->home で取得する事が出来ます。

#### path_to ####

HOME からの相対パスを絶対パスに変換して返します。

    my $view_dir = $config->path_to('view');

#### 複数の設定ファイルの読み込み

環境変数を元に複数の設定ファイルを読みこみ、マージする事が出来ます。

$ENV{'MYAPP_CONFIG'} が存在する場合はその変数自体を設定ファイルとして読み込みます。
/ から始まる場合は絶対パスとして扱い、/ から始まらない場合は HOMEからの相対パスとして扱い、$config->path_to を経由して読み込みます。

環境変数 $ENV{'MYAPP_ENV'} が存在する場合は HOME 直下で config_${'MYAPP_ENV'}.pl と suffix をつけた設定ファイルが読み込まれます。
デフォルトの config.pl で指定された値をベースとして、上書きされます。

### Context ###

    package MyApp::Context;
     
    use strict;
    use warnings;
    use parent 'Pickles::Context';
     
    __PACKAGE__->load_plugins(qw(Encode));
    
    1;
    
    __END__

### プラグイン ###

デフォルトでは文字エンコーディングを適切に取り扱うための Pickles::Plugin::Encode をロードしています。



挙動のカスタマイズは Context を拡張する事によって行います。
Context の拡張は主に継承によるメソッドの追加、オーバーライド、Class::Trigger によるフック関数の実行によって行います。

### Object Container としての挙動 ###

Pickles は Model の機構を持ちませんが、コードを書きやすくするため、Context が Object Container として振る舞う事が出来ます。






