import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import {
  DeleteCommand,
  DynamoDBDocumentClient,
  GetCommand,
  PutCommand,
  UpdateCommand,
} from '@aws-sdk/lib-dynamodb';
import { v4 as uuidv4 } from 'uuid';
import { coffeeOrderSchema, coffeeOrderUpdateSchema } from './types';

const client = new DynamoDBClient({ region: 'ap-southeast-2' });
const docClient = DynamoDBDocumentClient.from(client);
const tableName = process.env.TABLE_NAME || '';

export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  const { httpMethod, body, pathParameters } = event;
  let response: APIGatewayProxyResult;

  switch (httpMethod) {
    case 'GET': {
      const getItemCommand = new GetCommand({
        TableName: tableName!,
        Key: {
          id: pathParameters!.id as any,
        },
      });
      const getItemResult = await docClient.send(getItemCommand);
      response = {
        statusCode: 200,
        body: JSON.stringify(getItemResult.Item),
      };
      break;
    }

    case 'POST': {
      try {
        const postBody = JSON.parse(body || '{}');
        const coffeeOrder = coffeeOrderSchema.safeParse(postBody);
        if (coffeeOrder.error) {
          response = {
            statusCode: 400,
            body: coffeeOrder.error.issues[0].message,
          };
          break;
        }
        const newId = uuidv4();
        const newItem = {
          ...coffeeOrder.data,
          id: newId,
        };
        const putItemCommand = new PutCommand({
          TableName: tableName,
          Item: newItem,
        });
        await docClient.send(putItemCommand);
        response = {
          statusCode: 201,
          body: JSON.stringify(newItem),
        };
      } catch (err) {
        console.error(err);
        response = {
          statusCode: 500,
          body: JSON.stringify(err),
        };
      }
      break;
    }

    case 'PATCH': {
      const postBody = JSON.parse(body || '{}');
      const coffeeOrder = coffeeOrderUpdateSchema.safeParse(postBody);
      if (coffeeOrder.error) {
        response = {
          statusCode: 400,
          body: coffeeOrder.error.issues[0].message,
        };
      }
      const updateItemParams = new UpdateCommand({
        TableName: tableName,
        Key: {
          id: pathParameters!.id as any,
        },
        UpdateExpression: `set ${[
          coffeeOrder.data?.coffeeType && `coffeeType = :coffeeType`,
          coffeeOrder.data?.milkType && `milkType = :milkType`,
          coffeeOrder.data?.personName && `personName = :personName`,
        ]
          .filter((x) => x != undefined)
          .join(', ')}
        `,
        ExpressionAttributeValues: {
          ':coffeeType': coffeeOrder.data?.coffeeType,
          ':milkType': coffeeOrder.data?.milkType,
          ':personName': coffeeOrder.data?.personName,
        },
      });
      await docClient.send(updateItemParams);
      response = {
        statusCode: 201,
        body: 'Successfully Updated',
      };
      break;
    }

    case 'DELETE': {
      const deleteItemCommand = new DeleteCommand({
        TableName: tableName,
        Key: {
          id: pathParameters!.id! as any,
        },
      });
      await docClient.send(deleteItemCommand);
      response = {
        statusCode: 200,
        body: JSON.stringify({
          message: 'Item deleted',
        }),
      };
      break;
    }

    default: {
      response = {
        statusCode: 405,
        body: JSON.stringify({
          error: 'Method Not Allowed',
        }),
      };
      break;
    }
  }

  return response;
};
