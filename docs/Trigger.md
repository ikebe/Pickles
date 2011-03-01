# トリガー

トリガーは認証機構や後処理を実装するのに使用する。

pre_action, post_action のみControllerクラスで定義し、その他は全てContextで定義する。

## チャート

- Context->new ( 以下 Context は $c と表記 )
    - $c->call_trigger(**'init'**);
        - セッション情報復元
        - リクエストのエンコーディング変換
- $c->dispatch
    - routes.pl によるディスパッチ処理, $controller 確定
    - $controller->new
    - $controller->init ... override して良い ?
    - $action 確定
    - $c->abort; 有効 ここから
    - $c->call_trigger(**'pre_dispatch'**);
        - 権限チェック, 失敗時 reidrect, abort
    - $controller->execute
        - $controller->call_trigger(**'pre_action'**, $c, $action);
            - 特定コントローラー依存のアクション前処理
        - $controller->$action($c);
            - アクション
        - $controller->call_trigger(**'post_action'**, $c, $action);
            - 特定コントローラー依存のアクション後処理
    - $c->call_trigger(**'post_dispatch'**);
        - 全コントローラー共通のアクション後処理
    - $c->abort; 有効 ここまで
    - $c->finished(1) してない場合
        - $c->call_trigger(**'pre_render'**);
            - $c->stash->{VIEW_TEMPLATE} の加工が出来る最後のトリガー
        - $c->render; 
            - View::Xslate->render
        - $c->call_trigger(**'post_render'**);
            - Plugin::FillInform フォームへの値復元
    - $c->finalize
        - $c->call_trigger(**'pre_finalize'**);
            - Plugin::Encode レスポンスエンコーディング変換
            - Plugin::Session レスポンスにセッションID埋め込み
        - $c->res->finalize; クライアントに出力
        - $c->call_trigger(**'post_finalize'**);
            - Plugin::Session セッション永続化
            - DB接続クリーンナップ


