% include('header.tpl', page_title='chrome-profile-view', include_jquery=True)

        <script>
            % include('localstorage_hosts_script.tpl', selector="#local_storage_host_list")
            % include('sessionstorage_hosts_script.tpl', selector="#session_storage_host_list")
        </script>
        <div id="error_box"></div>
        
        <h1>chrome-profile-view</h1>
        <h2>History</h2>
        <p><a href="/history">View History Data</a>

        <h2>Cache</h2>
        <p><a href="/cache">View Cache Data</a>
        
        <h2>Local Storage Hosts</h2>
        <ul id="local_storage_host_list">

        </ul>
        <h2>Session Storage Hosts</h2>
        <ul id="session_storage_host_list">

        </ul>

% include('footer.tpl')