% setdefault("include_d3", False)

<html>
    <head>
        <title>{{page_title}}</title>
        <link rel="stylesheet" href="/style/main.css">
        % if include_jquery:
        <script src="/js/jquery-3.7.1.min.js"></script>
        % end
        % if include_d3:
        <script src="/js/d3.v7.min.js"></script>
        % end
    </head>
    <body>