clear all;
close all;
% 生成檔案路徑列表
base_path = 'C:\Users\user\Desktop\lane_1_test\label\';
imagebath_path = 'C:\Users\user\Desktop\lane_1_test\graph\';
file_paths = cell(1, 108);

a = arduino('COM6', 'Uno');
% 定義 RGB LED 的腳位（假設它們是 PWM 腳位）
redPin = 'D10';   % 紅色 LED
greenPin = 'D6'; % 綠色 LED
bluePin = 'D9';  % 藍色 LED

% 定義蜂鳴器腳位
buzzerPin = 'D3';

% 設定初始狀態
writePWMDutyCycle(a, buzzerPin, 0);
writePWMDutyCycle(a, redPin, 1);
writePWMDutyCycle(a, greenPin, 1);
writePWMDutyCycle(a, bluePin, 1);

for i = 1:108
    file_paths{i} = [base_path, num2str(i), '.txt'];
end

euclidean_distances = []; % 用於儲存歐氏距離

fileID = -1; % 初始化 fileID 變數
car_num = 0; % 初始化車輛數目
for i = 1:length(file_paths)
    % 嘗試打開檔案
    try
        fileID = fopen(file_paths{i}, 'r');

        % 檢查是否成功打開檔案
        if fileID == -1
            error(['無法打開檔案：', file_paths{i}]);
        end

        % 讀取檔案內容
        data = fscanf(fileID, '%f'); % 讀取所有數字

        % 關閉檔案
        fclose(fileID);

        % 將資料分成類別、x座標和y座標
        num_rows = length(data) / 5; % 假設每行有5個數字
        data_matrix = reshape(data, [5, num_rows])'; % 轉換為矩陣

        % 分別存儲類別、x座標和y座標
        class_data = data_matrix(:, 1);
        x_data = data_matrix(:, 2);
        y_data = data_matrix(:, 3);

        % 處理類別相同的檔案
        if mod(i,6) == 1
            % 第一個檔案，僅保存資料
            car_num = car_num + 1;
            disp(['第', num2str(car_num), '台車輛進入道路']);
            class1 = class_data;
            x1 = x_data;
            y1 = y_data;
            imageName = [imagebath_path, num2str(i), '.jpg'];
            img = imread(imageName);
            imshow(img);
            title(['第', num2str(car_num), '台車']);
            %ylabel('車輛速度為:',num2str(target_V),'車輛再',num2str(target_Time),'秒後抵達路口');
        else
            % 第二個檔案，進行計算
            class2 = class_data;
            x2 = x_data;
            y2 = y_data;
            % imageName = [imagebath_path, num2str(i), '.jpg'];
            % img = imread(imageName);
            % imshow(img);
            % title(['第', num2str(car_num), '台車']);
            % 判斷類別是否相同
            if all(class1 == class2)
                % 計算歐氏距離
                distance = sqrt((x2 - x1).^2 + (y2 - y1).^2);
                if mod(i,6) ~= 0
                    target_Vms = distance*50/(mod(i,6)*0.18);
                    target_V = target_Vms*3600/1000;
                else
                    target_Vms = distance*50/(6*0.18);
                    target_V = target_Vms*3600/1000;
                end
                target_V = sprintf('%.2f', target_V);
                target_Time = (250-distance*50)/(target_Vms);
                target_Time = sprintf('%.1f', target_Time);
                imageName = [imagebath_path, num2str(i), '.jpg'];
                img = imread(imageName);
                imshow(img);
                title(['第', num2str(car_num), '台車']);
                xlabel(['車輛速度為：',num2str(target_V),'km/hr，車輛再 ',num2str(target_Time),' 秒後抵達路口']);
                % 顯示歐氏距離
                if class_data == 0
                    disp(['目標車輛類別為小型車輛,其速度為：', num2str(target_V), 'km/hr']);
                    if str2double(target_V) >= 70
                        % disp(['目標車輛已超速，視為危險車輛']);
                        % writePWMDutyCycle(a, buzzerPin, 0.5); % 開啟蜂鳴器
                        writePWMDutyCycle(a, redPin, 0); % 亮紅燈
                        writePWMDutyCycle(a, greenPin, 1);
                        writePWMDutyCycle(a, bluePin, 1);
                        % disp(['目標車輛即將在',target_Time,'秒後到達路口']);
                        pause(1);
                    else
                        % disp(['目標車輛速度正常']);
                        writePWMDutyCycle(a, buzzerPin, 0); % 關閉蜂鳴器
                        writePWMDutyCycle(a, redPin, 1);
                        writePWMDutyCycle(a, greenPin, 0); % 亮綠燈
                        writePWMDutyCycle(a, bluePin, 1);
                        % disp(['目標車輛即將在',target_Time,'秒後到達路口']);
                        pause(1);
                    end
                else
                    disp(['目標車輛類別為卡車,其速度為：', num2str(target_V), 'km/hr']);
                    if str2double(target_V) >= 60
                        % disp(['目標車輛已超速，視為危險車輛']);
                        % writePSWMDutyCycle(a, buzzerPin, 0.5); % 開啟蜂鳴器
                        writePWMDutyCycle(a, redPin, 0); % 亮紅燈
                        writePWMDutyCycle(a, greenPin, 1);
                        writePWMDutyCycle(a, bluePin, 1);
                        % disp(['目標車輛即將在',target_Time,'秒後到達路口']);
                        pause(1);
                    else
                        % disp(['目標車輛速度正常']);
                        writePWMDutyCycle(a, buzzerPin, 0); % 關閉蜂鳴器
                        writePWMDutyCycle(a, redPin, 1);
                        writePWMDutyCycle(a, greenPin, 0); % 亮綠燈
                        writePWMDutyCycle(a, bluePin, 1);
                        % disp(['目標車輛即將在',target_Time,'秒後到達路口']);
                        pause(1);
                    end
                end
                % 將歐氏距離加入結果集
                euclidean_distances = [euclidean_distances; str2double(target_V)];
            else
                disp('兩個檔案的類別不同，無法計算歐氏距離。');
            end
        end

    catch ME
        % 處理例外
        disp(['發生錯誤：', ME.message]);
        if exist('fileID', 'var') && fileID ~= -1
            fclose(fileID);
        end
    end
end
% 清理並刪除 Arduino 對象
clear all;