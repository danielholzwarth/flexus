package parser

import (
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
)

func ParseRequestBody(r *http.Request, types map[string]string) (map[string]any, error) {
	var requestBody map[string]interface{}

	body, err := io.ReadAll(r.Body)
	if err != nil {
		return nil, err
	}

	if err := json.Unmarshal(body, &requestBody); err != nil {
		return nil, err
	}

	bodyData := make(map[string]interface{})

	for key, dataType := range types {
		value, exists := requestBody[key]
		if !exists {
			return nil, errors.New("key " + key + " not found in request body")
		}

		switch dataType {
		case "float":
			valueFloat, ok := value.(float64)
			if !ok {
				return nil, errors.New("type assertion to float64 failed for key " + key)
			}
			bodyData[key] = valueFloat

		case "int":
			valueFloat, ok := value.(float64)
			if !ok {
				return nil, errors.New("type assertion to float64 failed for key " + key)
			}
			bodyData[key] = int(valueFloat)

		case "string":
			valueStr, ok := value.(string)
			if !ok {
				return nil, errors.New("type assertion to string failed for key " + key)
			}
			bodyData[key] = valueStr

		case "bool":
			valueBool, ok := value.(bool)
			if !ok {
				return nil, errors.New("type assertion to bool failed for key " + key)
			}
			bodyData[key] = valueBool

		default:
			return nil, errors.New("unsupported data type for key " + key)
		}
	}

	return bodyData, nil
}

func ParseParam(r *http.Request, key string, dataType string) (any, error) {
	urlParam := chi.URLParam(r, key)
	var param any
	var err error

	switch dataType {
	case "float":
		param, err = strconv.ParseFloat(urlParam, 64)
		if err != nil {
			return nil, errors.New("type assertion to float64 failed for key " + key + " with value " + urlParam)
		}

	case "int":
		param, err = strconv.Atoi(urlParam)
		if err != nil {
			return nil, errors.New("type assertion to int failed for key " + key + " with value " + urlParam)
		}

	case "string":
		param = urlParam

	case "bool":
		param, err = strconv.ParseBool(urlParam)
		if err != nil {
			return nil, errors.New("type assertion to bool failed for key " + key + " with value " + urlParam)
		}

	default:
		return nil, errors.New("unsupported data type for key " + key)
	}

	return param, nil
}
